import SwiftUI

struct TagView: View {
    let tag: Tag
    var size: TagSize = .medium

    var body: some View {
        HStack(spacing: size.spacing) {
            Circle()
                .fill(tag.color.color)
                .frame(width: size.dotSize, height: size.dotSize)

            Text(tag.name)
                .font(size.font)
                .fontWeight(.medium)
                .foregroundStyle(tag.color.color)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(tag.color.lightColor)
        .clipShape(Capsule())
    }

    enum TagSize {
        case small
        case medium
        case large

        var font: Font {
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

        var dotSize: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
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

#Preview("Tag Sizes") {
    VStack(spacing: 16) {
        TagView(tag: Tag(name: "Feature", color: .blue), size: .small)
        TagView(tag: Tag(name: "Feature", color: .blue), size: .medium)
        TagView(tag: Tag(name: "Feature", color: .blue), size: .large)
    }
    .padding()
}

#Preview("Tag Colors") {
    VStack(spacing: 12) {
        TagView(tag: Tag(name: "UI", color: .blue))
        TagView(tag: Tag(name: "Bug", color: .red))
        TagView(tag: Tag(name: "Enhancement", color: .green))
        TagView(tag: Tag(name: "Feature", color: .purple))
        TagView(tag: Tag(name: "Export", color: .orange))
    }
    .padding()
}
