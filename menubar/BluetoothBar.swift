// BluetoothBar: menu bar icons for the AirPods and the Magic Keyboard.
//
//   Left-click   run the device's command from ~/.config/zsh/bluetooth.zsh:
//                  AirPods   connect / disconnect            (bt_toggle)
//                  Keyboard  forget, then pair and connect   (keyboard)
//   Right-click  status and Quit
//
// An icon is grey while its device is disconnected, and the result of a click
// shows briefly next to it. The app declares Bluetooth use in its Info.plist,
// so macOS asks once and then lets it (and the commands it runs) use Bluetooth.
// Device addresses and names come from bluetooth.zsh, so there's one place to
// change them. Build with ./build.sh.

import AppKit
import IOBluetooth
import ServiceManagement

let bluetoothZsh = NSHomeDirectory() + "/.config/zsh/bluetooth.zsh"

/// Run a zsh command with bluetooth.zsh loaded. Returns its exit status and output.
func zsh(_ command: String) -> (status: Int32, output: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    process.arguments = ["-f", "-c", "source '\(bluetoothZsh)' && \(command)"]
    var environment = ProcessInfo.processInfo.environment
    environment["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    process.environment = environment
    let output = Pipe()
    process.standardOutput = output
    process.standardError = FileHandle.nullDevice
    do { try process.run() } catch { return (-1, "") }
    let data = output.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return (process.terminationStatus, String(decoding: data, as: UTF8.self))
}

final class DeviceItem: NSObject {
    enum Kind { case toggle, repair }

    let name: String
    let address: String
    let command: String
    let kind: Kind
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var busy = false
    var flashTimer: Timer?

    init(name: String, address: String, symbol: String, command: String, kind: Kind) {
        self.name = name
        self.address = address
        self.command = command
        self.kind = kind
        super.init()
        item.autosaveName = symbol
        if let button = item.button {
            let image = NSImage(systemSymbolName: symbol, accessibilityDescription: name)
            image?.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeft
            button.target = self
            button.action = #selector(clicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        refresh()
    }

    var connected: Bool {
        IOBluetoothDevice(addressString: address)?.isConnected() ?? false
    }

    /// Grey while disconnected
    func refresh() {
        guard !busy else { return }
        item.button?.appearsDisabled = !connected
    }

    @objc func clicked() {
        if NSApp.currentEvent?.type == .rightMouseUp { showMenu() } else { run() }
    }

    func run() {
        guard !busy else { return }
        busy = true
        item.button?.appearsDisabled = false
        flash(kind == .repair ? "Switch it off and on…" : "…", seconds: nil)
        let command = self.command
        DispatchQueue.global(qos: .userInitiated).async {
            let result = zsh(command)
            DispatchQueue.main.async {
                self.busy = false
                switch self.kind {
                case .toggle:
                    self.flash(self.connected ? "✓ Connected" : "○ Disconnected", seconds: 4)
                case .repair:
                    self.flash(result.status == 0 ? "✓ Paired & connected" : "✗ Couldn't pair", seconds: 6)
                }
                self.refresh()
            }
        }
    }

    /// Show a short text next to the icon; nil seconds keeps it until the next flash
    func flash(_ text: String, seconds: Double?) {
        flashTimer?.invalidate()
        item.button?.title = " " + text
        guard let seconds else { return }
        flashTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
            self?.item.button?.title = ""
        }
    }

    func showMenu() {
        let menu = NSMenu()
        let status = menu.addItem(withTitle: "\(name): \(connected ? "connected" : "not connected")",
                                  action: nil, keyEquivalent: "")
        status.isEnabled = false
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
                       command: "keyboard", kind: .repair),
            DeviceItem(name: config[1], address: config[0], symbol: "airpods",
                       command: #"bt_toggle "$AIRPODS_BT_ADDRESS" "$AIRPODS_NAME""#, kind: .toggle),
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
