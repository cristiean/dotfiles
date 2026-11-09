// BluetoothBar: menu bar icons for the AirPods and the Magic Keyboard.
//
// What you see
//   One icon per device. It's drawn normally while the device is connected and
//   greyed out while it isn't, and it's re-checked every few seconds.
//
// What the clicks do
//   Right-click  runs the device's command:
//                  AirPods   connect if disconnected, disconnect if connected
//                  Keyboard  forget it, then pair and connect it again
//                While the command runs, the icon gets the system's highlight
//                (the rounded background a menu bar icon has while its menu is
//                open) and its steps show next to it ("Connecting",
//                "Pairing (2/10)", ...). The last one stays for a couple of
//                seconds, then the text and highlight go away.
//   Left-click   opens a menu: the device's status, the same command, and Quit.
//
// How it works
//   The app doesn't talk to Bluetooth itself. It runs the same zsh functions as
//   the terminal commands `airpods` and `keyboard`, from ~/.config/zsh/bluetooth.zsh,
//   and reads their progress. Device names and addresses also come from there,
//   so that file is the one place to change them.
//   macOS only lets an app (and the commands it runs) use Bluetooth if the app
//   declares it; Info.plist does that, and macOS asks once on first use.
//
// Building
//   ./build.sh compiles this file into ~/Applications/BluetoothBar.app and starts
//   it. setup.sh runs it on a new Mac. The app adds itself to Login Items.

import AppKit
import ServiceManagement

// MARK: - Settings

enum Settings {
    /// The zsh file with the Bluetooth functions and device names/addresses
    static let bluetoothFunctionsFile = NSHomeDirectory() + "/.config/zsh/bluetooth.zsh"

    /// Where the commands find blueutil and coreutils (Homebrew) and system tools
    static let commandSearchPath = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    /// How often each icon re-checks whether its device is connected
    static let connectionCheckInterval: TimeInterval = 5

    /// How long the last step of a command stays next to the icon
    static let resultDisplayDuration: TimeInterval = 2

    /// Icon size, chosen to match other apps' menu bar icons
    static let iconPointSize: CGFloat = 16
}

// MARK: - Running the Bluetooth commands

struct CommandResult {
    let exitStatus: Int32
    let output: String

    var succeeded: Bool { exitStatus == 0 }
}

/// Runs a zsh command with bluetooth.zsh loaded, and waits for it to finish.
///
/// If `onProgress` is given, the command runs with BT_PROGRESS set. bluetooth.zsh
/// then writes each step to stderr as "@progress <step>" instead of drawing its
/// terminal status line, and each step is passed to `onProgress` as it happens.
@discardableResult
func runBluetoothCommand(_ command: String,
                         onProgress: ((String) -> Void)? = nil) -> CommandResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    // -f: skip the user's zsh startup files; only bluetooth.zsh is needed
    process.arguments = ["-f", "-c", "source '\(Settings.bluetoothFunctionsFile)' && \(command)"]

    var environment = ProcessInfo.processInfo.environment
    environment["PATH"] = Settings.commandSearchPath
    environment["LANG"] = "en_US.UTF-8"      // device names contain emoji
    if onProgress != nil { environment["BT_PROGRESS"] = "1" }
    process.environment = environment

    let standardOutput = Pipe()
    let standardError = Pipe()
    process.standardOutput = standardOutput
    process.standardError = standardError

    // Collect stderr as it arrives and pass on complete "@progress" lines
    let progressPrefix = "@progress "
    var unfinishedLine = ""
    standardError.fileHandleForReading.readabilityHandler = { handle in
        unfinishedLine += String(decoding: handle.availableData, as: UTF8.self)
        while let newline = unfinishedLine.firstIndex(of: "\n") {
            let line = String(unfinishedLine[..<newline])
            unfinishedLine = String(unfinishedLine[unfinishedLine.index(after: newline)...])
            if line.hasPrefix(progressPrefix) {
                onProgress?(String(line.dropFirst(progressPrefix.count)))
            }
        }
    }

    do {
        try process.run()
    } catch {
        return CommandResult(exitStatus: -1, output: "")
    }
    let outputData = standardOutput.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    standardError.fileHandleForReading.readabilityHandler = nil
    return CommandResult(exitStatus: process.terminationStatus,
                         output: String(decoding: outputData, as: UTF8.self))
}

// MARK: - Devices

struct Device {
    let name: String       // e.g. "🍤 shrimps", shown in the menu
    let address: String    // Bluetooth address, e.g. "74-77-86-6d-d5-a9"
}

/// Reads the AirPods and keyboard names and addresses from bluetooth.zsh
func readDevicesFromBluetoothFunctions() -> (airpods: Device, keyboard: Device)? {
    let printDevices = #"""
        print -r -- "$AIRPODS_BT_ADDRESS"; print -r -- "$AIRPODS_NAME"
        print -r -- "$KEYBOARD_BT_ADDRESS"; print -r -- "$KEYBOARD_NAME"
        """#
    let lines = runBluetoothCommand(printDevices).output
        .split(separator: "\n").map(String.init)
    guard lines.count == 4 else { return nil }
    return (airpods: Device(name: lines[1], address: lines[0]),
            keyboard: Device(name: lines[3], address: lines[2]))
}

// MARK: - One menu bar icon per device

/// What clicking a device's icon does
struct DeviceAction {
    /// The zsh command to run, e.g. `keyboard`
    let command: String
    /// The action's name in the menu, given whether the device is connected
    let menuTitle: (_ isConnected: Bool) -> String
}

final class DeviceMenuBarIcon: NSObject {
    private let device: Device
    private let action: DeviceAction
    private let statusItem: NSStatusItem

    private var isConnected = false
    private var isRunningAction = false
    private var hideStatusTextTimer: Timer?

    /// - Parameters:
    ///   - id: a stable name macOS uses to remember the icon's position
    ///   - symbolName: the SF Symbol to show, e.g. "airpodspro"
    init(id: String, device: Device, symbolName: String, action: DeviceAction) {
        self.device = device
        self.action = action
        // Square (icon-sized) while idle; it widens only while showing text
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()

        statusItem.autosaveName = "BluetoothBar-\(id)"
        if let button = statusItem.button {
            button.image = Self.menuBarIcon(symbolName: symbolName, description: device.name)
            button.imagePosition = .imageLeft
            button.appearsDisabled = true        // grey until the first check
            button.target = self
            button.action = #selector(handleClick)
            button.sendAction(on: [.leftMouseDown, .rightMouseUp])
        }
        refreshConnectionState()
    }

    /// An SF Symbol sized like other menu bar icons. As a template image it takes
    /// the menu bar's own colour, and turns grey when the button is disabled.
    private static func menuBarIcon(symbolName: String, description: String) -> NSImage? {
        let size = NSImage.SymbolConfiguration(pointSize: Settings.iconPointSize, weight: .regular)
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: description)?
            .withSymbolConfiguration(size)
        image?.isTemplate = true
        return image
    }

    // MARK: Connection state

    /// Checks the connection the same way the terminal commands do (bt_get_state,
    /// which uses blueutil), then greys the icon out if the device isn't connected.
    func refreshConnectionState() {
        let address = device.address
        DispatchQueue.global(qos: .utility).async {
            let state = runBluetoothCommand("bt_get_state '\(address)'").output
                .trimmingCharacters(in: .whitespacesAndNewlines)
            DispatchQueue.main.async {
                self.isConnected = (state == "1")
                // While an action runs, the icon stays drawn normally
                if !self.isRunningAction {
                    self.statusItem.button?.appearsDisabled = !self.isConnected
                }
            }
        }
    }

    // MARK: Clicks

    @objc private func handleClick() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            runAction()
        } else {
            showMenu()
        }
    }

    /// Runs the device's command in the background, showing each step next to
    /// the icon. Clicks while it's running are ignored.
    @objc private func runAction() {
        guard !isRunningAction else { return }
        isRunningAction = true
        hideStatusTextTimer?.invalidate()
        statusItem.button?.appearsDisabled = false

        // The system's own selected-state background, so it looks like any
        // other menu bar icon in use (Apple's guidelines leave colour to macOS)
        statusItem.button?.highlight(true)

        let command = action.command
        DispatchQueue.global(qos: .userInitiated).async {
            runBluetoothCommand(command) { step in
                DispatchQueue.main.async { self.showStatusText(step) }
            }
            DispatchQueue.main.async {
                self.isRunningAction = false
                self.hideStatusTextTimer = Timer.scheduledTimer(
                    withTimeInterval: Settings.resultDisplayDuration, repeats: false
                ) { _ in
                    self.showStatusText(nil)
                }
                self.refreshConnectionState()
            }
        }
    }

    /// Shows text next to the icon, or the icon alone (and no highlight) when
    /// `text` is nil
    private func showStatusText(_ text: String?) {
        if let text {
            statusItem.length = NSStatusItem.variableLength
            statusItem.button?.title = " " + text + " "     // padding inside the highlight
        } else {
            statusItem.button?.title = ""
            statusItem.length = NSStatusItem.squareLength
            statusItem.button?.highlight(false)
        }
    }

    /// The left-click menu: status (greyed, not clickable), the action, and Quit
    private func showMenu() {
        let menu = NSMenu()

        let status = isConnected ? "connected" : "not connected"
        menu.addItem(withTitle: "\(device.name): \(status)", action: nil, keyEquivalent: "")
            .isEnabled = false

        let actionItem = menu.addItem(withTitle: action.menuTitle(isConnected),
                                      action: #selector(runAction), keyEquivalent: "")
        actionItem.target = self
        actionItem.isEnabled = !isRunningAction

        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit BluetoothBar",
                     action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // Attach the menu only for this click, so right-clicks still run the action
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
}

// MARK: - App startup

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var icons: [DeviceMenuBarIcon] = []
    private var connectionCheckTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let devices = readDevicesFromBluetoothFunctions() else {
            showErrorAndQuit("BluetoothBar couldn't read the devices from \(Settings.bluetoothFunctionsFile)")
            return
        }

        // Menu bar icons are added right to left, so the keyboard ends up to the
        // right of the AirPods
        icons = [
            DeviceMenuBarIcon(
                id: "keyboard", device: devices.keyboard, symbolName: "keyboard",
                action: DeviceAction(command: "keyboard",
                                     menuTitle: { _ in "Re-pair" })),
            DeviceMenuBarIcon(
                id: "airpods", device: devices.airpods, symbolName: "airpodspro",
                action: DeviceAction(command: #"bt_toggle "$AIRPODS_BT_ADDRESS" "$AIRPODS_NAME""#,
                                     menuTitle: { isConnected in isConnected ? "Disconnect" : "Connect" })),
        ]

        connectionCheckTimer = Timer.scheduledTimer(
            withTimeInterval: Settings.connectionCheckInterval, repeats: true
        ) { [weak self] _ in
            self?.icons.forEach { $0.refreshConnectionState() }
        }

        // Start automatically at login (shows up in System Settings > Login Items)
        try? SMAppService.mainApp.register()
    }

    private func showErrorAndQuit(_ message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let appDelegate = AppDelegate()
app.delegate = appDelegate
app.setActivationPolicy(.accessory)      // menu bar only: no Dock icon or app menu
app.run()
