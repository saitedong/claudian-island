import AppKit
import SwiftUI

final class IslandPanel: NSPanel {
    private static let panelH: CGFloat = 36
    // 刘海宽约 230px（13"/14" MacBook Pro 实测），外接显示器用更宽的 bar
    private static let notchW: CGFloat    = 230
    private static let externalW: CGFloat = 320

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: IslandPanel.externalW, height: IslandPanel.panelH),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        isMovable = false
        ignoresMouseEvents = false

        let hosting = NSHostingView(rootView: IslandView())
        hosting.wantsLayer = true
        // nonactivatingPanel 不接管键盘焦点，但鼠标事件必须手动允许
        hosting.autoresizingMask = [.width, .height]
        contentView = hosting
    }

    // MARK: - Public

    func show() {
        reposition()
        orderFrontRegardless()
    }

    /// Obsidian 切换屏幕后调用（AppDelegate 监听通知触发）
    func followObsidian() {
        reposition()
    }

    // MARK: - Screen detection

    /// 判断是否是 MacBook 内置屏（用 CGDisplayIsBuiltin 最准确）
    static func isBuiltIn(_ screen: NSScreen) -> Bool {
        guard let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return false
        }
        return CGDisplayIsBuiltin(id.uint32Value) != 0
    }

    /// 该屏幕是否有刘海（macOS 12+）
    static func isNotchScreen(_ screen: NSScreen) -> Bool {
        if #available(macOS 12.0, *) {
            return screen.safeAreaInsets.top > 0
        }
        return false
    }

    /// 决策：应该把 island 显示在哪个屏幕、用哪种模式。
    ///
    /// 规则：
    ///   有外接显示器 → 显示在外接显示器上（浮动 bar 样式）
    ///   无外接显示器 → 显示在 MacBook 内置屏（刘海灵动岛样式）
    static func targetScreen() -> (screen: NSScreen, onNotch: Bool) {
        let externals = NSScreen.screens.filter { !isBuiltIn($0) }

        if let external = externals.first {
            // 接了外接显示器 → 固定显示在外接显示器顶部，bar 样式
            return (external, false)
        }

        // 无外接显示器 → 内置屏，检测是否有刘海
        let builtIn = NSScreen.screens.first { isBuiltIn($0) }
                   ?? NSScreen.main
                   ?? NSScreen.screens[0]
        return (builtIn, isNotchScreen(builtIn))
    }

    // MARK: - Positioning

    private func reposition() {
        let (screen, onNotch) = IslandPanel.targetScreen()
        let w: CGFloat = onNotch ? IslandPanel.notchW : IslandPanel.externalW
        let h: CGFloat = IslandPanel.panelH

        let x = screen.frame.origin.x + (screen.frame.width - w) / 2

        // 刘海屏：pill 从刘海底部向下延伸，内容完全在可见区域内
        // 外接显示器：贴屏幕顶部（menu bar 区域）
        let y: CGFloat = onNotch
            ? screen.visibleFrame.maxY - h
            : screen.frame.maxY - h

        IslandViewModel.shared.isOnNotchScreen = onNotch

        setFrame(NSRect(x: x, y: y, width: w, height: h), display: false)
        contentView?.frame = NSRect(x: 0, y: 0, width: w, height: h)
    }
}
