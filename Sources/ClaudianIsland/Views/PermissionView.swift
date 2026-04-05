import SwiftUI

struct PermissionView: View {
    let tool: String
    let viewModel: IslandViewModel

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.shield.fill")
                .foregroundStyle(.yellow)
                .font(.system(size: 14))

            Text(tool)
                .foregroundStyle(.white)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)

            Spacer()

            // Deny button
            Button {
                viewModel.permissionReply?("deny")
                Task { @MainActor in viewModel.transitionTo(.idle) }
            } label: {
                Text("拒绝")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(white: 0.35)))
            }
            .buttonStyle(.plain)

            // Allow button
            Button {
                viewModel.permissionReply?("allow")
                Task { @MainActor in viewModel.transitionTo(.idle) }
            } label: {
                Text("允许")
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
