import SwiftUI

struct NotificationView: View {
    let message: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bell.fill")
                .foregroundStyle(.white)
                .font(.system(size: 13))
            Text(message)
                .foregroundStyle(.white)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
            Spacer()
            Image(systemName: "arrow.up.right")
                .foregroundStyle(.white.opacity(0.7))
                .font(.system(size: 11))
        }
        .padding(.horizontal, 14)
    }
}
