import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var islandPanel: IslandPanel?
    private var socketServer: SocketServer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        islandPanel = IslandPanel()
        islandPanel?.show()

        socketServer = SocketServer()
        socketServer?.start()

        // 外接显示器插拔 / 排列改变时重新定位
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc private func handleScreenChange() {
        islandPanel?.followObsidian()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
