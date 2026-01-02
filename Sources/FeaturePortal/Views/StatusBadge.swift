import SwiftUI

struct StatusBadge: View {
    let status: FeatureStatus
    var size: BadgeSize = .medium

    var color: Color {
        switch status {
        case .pending: return .secondary
        case .approved: return .featurePortalPrimary
        case .inProgress: return .featurePortalOrange
        case .completed: return .featurePortalGreen
        case .rejected: return .featurePortalRed
        }
    }

    var body: some View {
        HStack(spacing: size.spacing) {
            Image(systemName: status.icon)
                .font(size.iconFont)

            Text(status.displayName)
                .font(size.textFont)
                .fontWeight(.semibold)
        }
        .foregroundStyle(color)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }

    enum BadgeSize {
        case small
        case medium
        case large

        var iconFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }

        var textFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return .grid(2)
            case .medium: return .grid(2)
            case .large: return .grid(3)
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return .grid(1)
            case .medium: return .grid(1)
            case .large: return .grid(2)
            }
        }

        var spacing: CGFloat {
            switch self {
            case .small: return .grid(1)
            case .medium: return .grid(1)
            case .large: return .grid(2)
            }
        }
    }
}

#Preview("Status Badges") {
    VStack(spacing: 16) {
        StatusBadge(status: .pending)
        StatusBadge(status: .approved)
        StatusBadge(status: .inProgress)
        StatusBadge(status: .completed)
        StatusBadge(status: .rejected)
    }
    .padding()
}

#Preview("Badge Sizes") {
    VStack(spacing: 16) {
        StatusBadge(status: .inProgress, size: .small)
        StatusBadge(status: .inProgress, size: .medium)
        StatusBadge(status: .inProgress, size: .large)
    }
    .padding()
}
