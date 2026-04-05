import AppKit
import Observation

enum IslandState: Equatable {
    case idle
    case complete
    case permission(tool: String, id: String)
    case question(id: String)
    case notification(message: String)

    static func == (lhs: IslandState, rhs: IslandState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.complete, .complete): return true
        case let (.permission(t1, i1), .permission(t2, i2)): return t1 == t2 && i1 == i2
        case let (.question(i1), .question(i2)): return i1 == i2
        case let (.notification(m1), .notification(m2)): return m1 == m2
        default: return false
        }
    }
}

@Observable
final class IslandViewModel {
    static let shared = IslandViewModel()

    var state: IslandState = .idle
    var isOnNotchScreen: Bool = true   // 由 IslandPanel.reposition() 更新
    // Called by SocketServer when user taps allow/deny
    var permissionReply: ((String) -> Void)?

    private init() {}

    @MainActor
    func transitionTo(_ newState: IslandState) {
        state = newState
        switch newState {
        case .complete:
            Task {
                try? await Task.sleep(for: .seconds(3))
                if case .complete = self.state { self.state = .idle }
            }
        case .notification:
            Task {
                try? await Task.sleep(for: .seconds(5))
                if case .notification = self.state { self.state = .idle }
            }
        default:
            break
        }
    }

    func focusObsidian() {
        NSAppleScript(source: "tell application \"Obsidian\" to activate")?.executeAndReturnError(nil)
    }
}
