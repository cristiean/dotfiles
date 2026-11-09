// BluetoothBar: menu bar icons for the AirPods and the Magic Keyboard.
//
// What you see
//   One icon per device. While resting (no status showing), it's drawn normally
//   if the device is connected and greyed out if it isn't, re-checked every few
//   seconds. While a status shows, the icon and text are always solid.
//
// What the clicks do
//   Right-click  runs the device's command:
//                  AirPods   connect if disconnected, disconnect if connected
//                  Keyboard  forget it, then pair and connect it again
//                While the command runs, the icon and its status ("Connecting",
//                "Searching", ...) sit on a rounded "pill" coloured by state:
//                blue while working, green when connected, grey when
//                disconnected, red when it failed. The last status stays for a
//                couple of seconds, then the text and pill go away.
//   Left-click   opens a menu: the device's status, the same command, and Quit.
//
// How it works
//   The app doesn't talk to Bluetooth itself. It runs the same zsh functions as
//   the terminal commands `airpods` and `keyboard`, from ~/.config/zsh/bluetooth.zsh,
//   and follows the state words they report (see bt_report there). Device names and addresses also come from there,
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

    // The pill shown while a status is up: a solid capsule in the state's colour
    // with a white icon and text, like macOS's own coloured indicators (e.g. the
    // screen-sharing one). Both icons use the same measurements.

    /// Capsule height. The menu bar is 24 pt tall, so this leaves 2 pt above and below.
    static let pillHeight: CGFloat = 20
    /// Space between the capsule's edge and the icon (and after the longest text)
    static let pillHorizontalPadding: CGFloat = 8
    /// Space between the icon and the text
    static let pillIconTextSpacing: CGFloat = 5
    /// Room reserved for the icon, so the text starts at the same place for
    /// every device even though their symbols differ in width
    static let pillIconSlotWidth: CGFloat = 22
    /// Menu bar text size, slightly bolder so white text reads well on colour
    static let pillFont = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .medium)
}

// MARK: - Running the Bluetooth commands

struct CommandResult {
    let exitStatus: Int32
    let output: String

    var succeeded: Bool { exitStatus == 0 }
}

/// Runs a zsh command with bluetooth.zsh loaded, and waits for it to finish.
///
/// If `onState` is given, the command runs with BT_PROGRESS set. bluetooth.zsh
/// then draws no terminal output and instead writes each state it reaches to
/// stderr as "@state <word>" (e.g. "@state searching"); each word is passed to
/// `onState` as it happens.
@discardableResult
func runBluetoothCommand(_ command: String,
                         onState: ((String) -> Void)? = nil) -> CommandResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    // -f: skip the user's zsh startup files; only bluetooth.zsh is needed
    process.arguments = ["-f", "-c", "source '\(Settings.bluetoothFunctionsFile)' && \(command)"]

    var environment = ProcessInfo.processInfo.environment
    environment["PATH"] = Settings.commandSearchPath
    environment["LANG"] = "en_US.UTF-8"      // device names contain emoji
    if onState != nil { environment["BT_PROGRESS"] = "1" }
    process.environment = environment

    let standardOutput = Pipe()
    let standardError = Pipe()
    process.standardOutput = standardOutput
    process.standardError = standardError

    // Collect stderr as it arrives and pass on complete "@state" lines
    let statePrefix = "@state "
    var unfinishedLine = ""
    standardError.fileHandleForReading.readabilityHandler = { handle in
        unfinishedLine += String(decoding: handle.availableData, as: UTF8.self)
        while let newline = unfinishedLine.firstIndex(of: "\n") {
            let line = String(unfinishedLine[..<newline])
            unfinishedLine = String(unfinishedLine[unfinishedLine.index(after: newline)...])
            if line.hasPrefix(statePrefix) {
                onState?(String(line.dropFirst(statePrefix.count)))
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

// MARK: - States: what the menu bar shows for each state word

struct StateAppearance {
    let text: String
    let color: NSColor
}

/// The text and pill colour for each state word bluetooth.zsh reports.
/// Colours are macOS's standard system colours, which adapt to light/dark mode.
let stateAppearances: [String: StateAppearance] = [
    // In progress
    "connecting":    StateAppearance(text: "Connecting",      color: .systemBlue),
    "disconnecting": StateAppearance(text: "Disconnecting",   color: .systemBlue),
    "unpairing":     StateAppearance(text: "Unpairing",       color: .systemBlue),
    "searching":     StateAppearance(text: "Searching",       color: .systemBlue),
    // Results
    "connected":     StateAppearance(text: "Connected",       color: .systemGreen),
    "disconnected":  StateAppearance(text: "Disconnected",    color: .systemGray),
    "timed-out":     StateAppearance(text: "Timed out",       color: .systemRed),
    "not-found":     StateAppearance(text: "Not found",       color: .systemRed),
    "unpair-failed": StateAppearance(text: "Couldn't unpair", color: .systemRed),
    "unknown":       StateAppearance(text: "Unknown",         color: .systemOrange),
]

func appearance(forState state: String) -> StateAppearance {
    stateAppearances[state] ?? StateAppearance(text: state, color: .systemGray)
}

// MARK: - The pill

/// One width for every pill, for both devices and every state: padding, the
/// icon, and the longest status text. Sharing it keeps both pills identical, and
/// a pill never changes width as its text changes.
let pillWidth: CGFloat = {
    let longestText = stateAppearances.values
        .map { ($0.text as NSString).size(withAttributes: [.font: Settings.pillFont]).width }
        .max() ?? 0
    return ceil(Settings.pillHorizontalPadding + Settings.pillIconSlotWidth
                + Settings.pillIconTextSpacing + longestText + Settings.pillHorizontalPadding)
}()

/// A solid capsule with a white icon and text. It's laid over the menu bar
/// button while a status shows, so its spacing is exact and the same for every
/// device (the button's own layout spaces images and titles unevenly).
final class PillView: NSView {
    private let iconView = NSImageView()
    private let label = NSTextField(labelWithString: "")
    private var color: NSColor = .systemBlue

    init(icon: NSImage?) {
        super.init(frame: .zero)
        iconView.image = icon
        iconView.contentTintColor = .white          // tints the template symbol
        iconView.imageScaling = .scaleProportionallyDown
        label.font = Settings.pillFont
        label.textColor = .white
        addSubview(iconView)
        addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    func show(text: String, color: NSColor) {
        label.stringValue = text
        self.color = color
        needsLayout = true
        needsDisplay = true
    }

    /// The capsule, vertically centred in the menu bar
    private var capsuleRect: NSRect {
        NSRect(x: 0, y: (bounds.height - Settings.pillHeight) / 2,
               width: bounds.width, height: Settings.pillHeight)
    }

    override func layout() {
        super.layout()
        let capsule = capsuleRect
        // Icon centred in its slot, after the left padding
        iconView.frame = NSRect(x: capsule.minX + Settings.pillHorizontalPadding, y: capsule.minY,
                                width: Settings.pillIconSlotWidth, height: capsule.height)
        // Text right after the icon slot, vertically centred
        label.sizeToFit()
        label.frame.origin = NSPoint(x: iconView.frame.maxX + Settings.pillIconTextSpacing,
                                     y: capsule.midY - label.frame.height / 2)
    }

    override func draw(_ dirtyRect: NSRect) {
        let radius = Settings.pillHeight / 2         // fully rounded ends
        color.setFill()
        NSBezierPath(roundedRect: capsuleRect, xRadius: radius, yRadius: radius).fill()
    }
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
    /// True while a status (text on a pill) is showing next to the icon
    private var isShowingState = false
    private var hideStatusTextTimer: Timer?
    private let icon: NSImage?
    private let pillView: PillView

    /// - Parameters:
    ///   - id: a stable name macOS uses to remember the icon's position
    ///   - symbolName: the SF Symbol to show, e.g. "airpodspro"
    init(id: String, device: Device, symbolName: String, action: DeviceAction) {
        self.device = device
        self.action = action
        self.icon = Self.menuBarIcon(symbolName: symbolName, description: device.name)
        self.pillView = PillView(icon: icon)
        // Square (icon-sized) while idle; it widens only while showing text
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()

        statusItem.autosaveName = "BluetoothBar-\(id)"
        if let button = statusItem.button {
            button.image = icon
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
                self.updateRestingLook()
            }
        }
    }

    /// Greys the icon out if the device isn't connected, but only while resting:
    /// greying a showing status would make its text hard to read on the pill
    private func updateRestingLook() {
        statusItem.button?.appearsDisabled = !isShowingState && !isConnected
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

        let command = action.command
        DispatchQueue.global(qos: .userInitiated).async {
            runBluetoothCommand(command) { state in
                DispatchQueue.main.async { self.showState(state) }
            }
            DispatchQueue.main.async {
                self.isRunningAction = false
                self.hideStatusTextTimer = Timer.scheduledTimer(
                    withTimeInterval: Settings.resultDisplayDuration, repeats: false
                ) { _ in
                    self.showState(nil)
                }
                self.refreshConnectionState()
            }
        }
    }

    /// Shows a state's text on its coloured pill, or the plain icon (no pill)
    /// when `state` is nil
    func showState(_ state: String?) {
        guard let button = statusItem.button else { return }
        guard let state else {
            isShowingState = false
            pillView.removeFromSuperview()
            button.image = icon
            statusItem.length = NSStatusItem.squareLength
            updateRestingLook()
            return
        }
        isShowingState = true
        button.appearsDisabled = false
        button.image = nil                           // the pill draws its own icon
        statusItem.length = pillWidth
        let shown = appearance(forState: state)
        pillView.show(text: shown.text, color: shown.color)
        if pillView.superview == nil {
            pillView.frame = button.bounds
            pillView.autoresizingMask = [.width, .height]
            button.addSubview(pillView)
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

        // For design work: `open BluetoothBar.app --args --preview searching`
        // shows that state on both icons and keeps it there, running nothing
        let arguments = CommandLine.arguments
        if let flag = arguments.firstIndex(of: "--preview"), flag + 1 < arguments.count {
            icons.forEach { $0.showState(arguments[flag + 1]) }
            return
        }

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
