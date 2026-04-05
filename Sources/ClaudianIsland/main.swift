import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
// No dock icon — set before run
app.setActivationPolicy(.accessory)
app.run()
