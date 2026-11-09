// BluetoothBar: menu bar icons for the AirPods and the Magic Keyboard.
//
//   Right-click  run the device's command from ~/.config/zsh/bluetooth.zsh:
//                  AirPods   connect / disconnect            (bt_toggle)
//                  Keyboard  forget, then pair and connect   (keyboard)
//   Left-click   menu: status, the same command, Quit
//
// An icon is grey while its device is disconnected. While a command runs, its
// steps show next to the icon (e.g. "Pairing (2/10)"), as reported by the shell
// functions with BT_PROGRESS set; the last one stays for a few seconds.
// The app declares Bluetooth use in its Info.plist, so macOS asks once and then
// lets the commands it runs use Bluetooth. Device addresses and names come from
// bluetooth.zsh, so there's one place to change them. Build with ./build.sh.

import AppKit
import ServiceManagement

let bluetoothZsh = NSHomeDirectory() + "/.config/zsh/bluetooth.zsh"

/// Run a zsh command with bluetooth.zsh loaded. Each "@progress <text>" line it
/// writes to stderr is passed to onProgress. Returns the exit status and stdout.
@discardableResult
func zsh(_ command: String, onProgress: ((String) -> Void)? = nil) -> (status: Int32, output: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    process.arguments = ["-f", "-c", "source '\(bluetoothZsh)' && \(command)"]
    var environment = ProcessInfo.processInfo.environment
    environment["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    environment["LANG"] = "en_US.UTF-8"
    if onProgress != nil { environment["BT_PROGRESS"] = "1" }
    process.environment = environment

    let output = Pipe()
    let errors = Pipe()
    process.standardOutput = output
    process.standardError = errors
    var pending = ""
    errors.fileHandleForReading.readabilityHandler = { handle in
        pending += String(decoding: handle.availableData, as: UTF8.self)
        while let newline = pending.firstIndex(of: "\n") {
            let line = String(pending[..<newline])
            pending = String(pending[pending.index(after: newline)...])
            if line.hasPrefix("@progress ") { onProgress?(String(line.dropFirst(10))) }
        }
    }
    do { try process.run() } catch { return (-1, "") }
    let data = output.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    errors.fileHandleForReading.readabilityHandler = nil
    return (process.terminationStatus, String(decoding: data, as: UTF8.self))
}

final class DeviceItem: NSObject {
    let name: String
    let address: String
    let command: String
    let actionTitle: (Bool) -> String       // menu item text, given "connected"
    // Square while idle, like other menu bar icons; wider only while text shows.
    // (Hidden Bar's collapse squeezed out the variable-width version.)
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var connected = false
    var busy = false
    var clearTimer: Timer?

    init(name: String, address: String, symbol: String, command: String,
         actionTitle: @escaping (Bool) -> String) {
        self.name = name
        self.address = address
        self.command = command
        self.actionTitle = actionTitle
        super.init()
        item.autosaveName = "BluetoothBar-\(symbol)"
        if let button = item.button {
            let image = NSImage(systemSymbolName: symbol, accessibilityDescription: name)
            image?.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeft
            button.appearsDisabled = true
            button.target = self
            button.action = #selector(clicked)
            button.sendAction(on: [.leftMouseDown, .rightMouseUp])
        }
        refresh()
    }

    /// Check the connection the same way the shell does (blueutil); grey if not connected
    func refresh() {
        let address = self.address
        DispatchQueue.global(qos: .utility).async {
            let state = zsh("bt_get_state '\(address)'").output.trimmingCharacters(in: .whitespacesAndNewlines)
            DispatchQueue.main.async {
                self.connected = (state == "1")
                if !self.busy { self.item.button?.appearsDisabled = !self.connected }
            }
        }
    }

    @objc func clicked() {
        if NSApp.currentEvent?.type == .rightMouseUp { run() } else { showMenu() }
    }

    @objc func run() {
        guard !busy else { return }
        busy = true
        clearTimer?.invalidate()
        item.button?.appearsDisabled = false
        let command = self.command
        DispatchQueue.global(qos: .userInitiated).async {
            zsh(command) { text in
                DispatchQueue.main.async { self.show(text) }
            }
            DispatchQueue.main.async {
                self.busy = false
                self.clearTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
                    self.show(nil)
                }
                self.refresh()
            }
        }
    }

    /// Text next to the icon, or nil for the icon alone
    func show(_ text: String?) {
        if let text {
            item.length = NSStatusItem.variableLength
            item.button?.title = " " + text
        } else {
            item.button?.title = ""
            item.length = NSStatusItem.squareLength
        }
    }

    func showMenu() {
        let menu = NSMenu()
        let status = menu.addItem(withTitle: "\(name): \(connected ? "connected" : "not connected")",
                                  action: nil, keyEquivalent: "")
        status.isEnabled = false
        let action = menu.addItem(withTitle: actionTitle(connected), action: #selector(run), keyEquivalent: "")
        action.target = self
        action.isEnabled = !busy
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit BluetoothBar",
                     action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = menu
        item.button?.performClick(nil)
        item.menu = nil
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var items: [DeviceItem] = []
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let names = #"""
            print -r -- "$AIRPODS_BT_ADDRESS"; print -r -- "$AIRPODS_NAME"
            print -r -- "$KEYBOARD_BT_ADDRESS"; print -r -- "$KEYBOARD_NAME"
            """#
        let config = zsh(names).output.split(separator: "\n").map(String.init)
        guard config.count == 4 else {
            let alert = NSAlert()
            alert.messageText = "BluetoothBar couldn't read the devices from \(bluetoothZsh)"
            alert.runModal()
            NSApp.terminate(nil)
            return
        }
        // Created right to left: the keyboard ends up right of the AirPods
        items = [
            DeviceItem(name: config[3], address: config[2], symbol: "keyboard",
                       command: "keyboard", actionTitle: { _ in "Re-pair" }),
            DeviceItem(name: config[1], address: config[0], symbol: "airpods",
                       command: #"bt_toggle "$AIRPODS_BT_ADDRESS" "$AIRPODS_NAME""#,
                       actionTitle: { $0 ? "Disconnect" : "Connect" }),
        ]
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.items.forEach { $0.refresh() }
        }
        try? SMAppService.mainApp.register()     // start at login
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)               // menu bar only, no Dock icon
app.run()
