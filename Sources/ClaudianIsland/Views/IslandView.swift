import SwiftUI

struct IslandView: View {
    @State private var viewModel = IslandViewModel.shared

    // 刘海屏：完全圆角贴合刘海；外接显示器：圆角稍小 + 轻阴影增加存在感
    private var cornerRadius: CGFloat { viewModel.isOnNotchScreen ? 20 : 12 }
    private var shadowRadius: CGFloat { viewModel.isOnNotchScreen ?  0 :  6 }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                switch viewModel.state {
                case .idle:
                    Color.clear

                case .complete:
                    pill(CompleteView(), color: Color(red: 0.08, green: 0.55, blue: 0.18))

                case .permission(let tool, _):
                    pill(PermissionView(tool: tool), color: Color(white: 0.12))

                case .question:
                    pill(AskUserQuestionView(), color: Color(red: 0.18, green: 0.32, blue: 0.68))

                case .notification(let message):
                    pill(NotificationView(message: message), color: Color(red: 0.65, green: 0.38, blue: 0.05))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.state)
        }
    }

    /// 统一的 pill 容器：点击任何状态 → 跳 Obsidian + 立即消失
    @ViewBuilder
    private func pill<V: View>(_ content: V, color: Color) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(color)
                    .shadow(color: .black.opacity(0.4), radius: shadowRadius, y: 3)
            )
            .padding(.horizontal, 4)
            .transition(.scale(scale: 0.6).combined(with: .opacity))
            .onTapGesture {
                viewModel.focusObsidian()
                Task { @MainActor in viewModel.transitionTo(.idle) }
            }
    }
}
