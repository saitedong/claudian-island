import SwiftUI

struct AskUserQuestionView: View {
    let viewModel: IslandViewModel

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "questionmark.bubble.fill")
                .foregroundStyle(.white)
                .font(.system(size: 14))

            Text("Obsidian 有提问")
                .foregroundStyle(.white)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)

            Spacer()

            Button {
                viewModel.focusObsidian()
                Task { @MainActor in viewModel.transitionTo(.idle) }
            } label: {
                Text("去 Obsidian")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
    }
}
