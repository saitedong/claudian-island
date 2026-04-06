import SwiftUI

struct AskUserQuestionView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "questionmark.bubble.fill")
                .foregroundStyle(.white)
                .font(.system(size: 14, weight: .semibold))
            Text("有提问待回答")
                .foregroundStyle(.white)
                .font(.system(size: 13, weight: .medium))
            Spacer()
            Image(systemName: "arrow.up.right")
                .foregroundStyle(.white.opacity(0.7))
                .font(.system(size: 11))
        }
        .padding(.horizontal, 14)
    }
}
