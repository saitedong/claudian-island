import SwiftUI

struct PermissionView: View {
    let tool: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.shield.fill")
                .foregroundStyle(.yellow)
                .font(.system(size: 14, weight: .semibold))
            Text("\(tool) 需要审批")
                .foregroundStyle(.white)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
            Spacer()
            Image(systemName: "arrow.up.right")
                .foregroundStyle(.white.opacity(0.7))
                .font(.system(size: 11))
        }
        .padding(.horizontal, 14)
    }
}
