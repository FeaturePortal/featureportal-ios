import SwiftUI

struct SpeechBubbleView: View {
    var message: String
    var ctaText: String
    var onTap: () -> Void
    var onClose: () -> Void
    var onDontShowAgain: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .grid(3)) {
            // Close button
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            // Message
            Text("Got an idea?")
                .font(.headline)
                .foregroundStyle(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // CTA Button
            Button(action: onTap) {
                Text(ctaText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, .grid(4))
                    .padding(.vertical, .grid(3))
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.featurePortalPrimary, .featurePortalSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .featurePortalButtonShadow()
            }
            .buttonStyle(.plain)

            // Don't show again
            Button(action: onDontShowAgain) {
                Text("Don't show again")
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.7))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.grid(4))
        .background(Color.featurePortalCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.featurePortalBorder.opacity(0.5), lineWidth: 0.5)
        )
        .featurePortalCardShadow()
        .frame(maxWidth: 240)
    }
}
