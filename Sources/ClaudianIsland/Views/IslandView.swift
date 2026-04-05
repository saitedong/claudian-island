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
                    CompleteView()
                        .onTapGesture { viewModel.focusObsidian() }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(pillBg(Color(red: 0.08, green: 0.55, blue: 0.18)))
                        .padding(.horizontal, 4)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))

                case .permission(let tool, _):
                    PermissionView(tool: tool, viewModel: viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(pillBg(Color(white: 0.12)))
                        .padding(.horizontal, 4)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))

                case .question:
                    AskUserQuestionView(viewModel: viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(pillBg(Color(red: 0.18, green: 0.32, blue: 0.68)))
                        .padding(.horizontal, 4)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))

                case .notification(let message):
                    NotificationView(message: message)
                        .onTapGesture { viewModel.focusObsidian() }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(pillBg(Color(red: 0.65, green: 0.38, blue: 0.05)))
                        .padding(.horizontal, 4)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.state)
        }
    }

    @ViewBuilder
    private func pillBg(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(color)
            .shadow(color: .black.opacity(0.4), radius: shadowRadius, y: 3)
    }
}
