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
    var isOnNotchScreen: Bool = true

    private var pendingStopTask: Task<Void, Never>?

    private init() {}

    /// 收到 Stop → 启动 5 秒 timer。
    /// 5 秒内如果有 tool_activity / permission / question → timer 被取消（Claude 还在干活）。
    /// 5 秒安静 → 弹 ✓（任务真正结束了）。
    @MainActor
    func scheduleStop() {
        pendingStopTask?.cancel()
        pendingStopTask = Task {
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled else { return }
            if case .idle = self.state {
                self.transitionTo(.complete)
            }
        }
    }

    /// Claude 正在调用工具 → 取消待弹的 ✓ + 清除审批/提问状态（说明用户已在 Obsidian 操作完了）
    @MainActor
    func cancelPendingStop() {
        pendingStopTask?.cancel()
        pendingStopTask = nil
        // 如果当前是审批或提问状态，tool_activity 说明 Claude 已经继续工作了 → 清除
        switch state {
        case .permission, .question:
            state = .idle
        default:
            break
        }
    }

    @MainActor
    func transitionTo(_ newState: IslandState) {
        // 活跃事件 → Claude 还在干活，取消待定的 ✓
        switch newState {
        case .permission, .question, .notification:
            cancelPendingStop()
        default:
            break
        }

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
