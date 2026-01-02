import SwiftUI

public struct RoadmapView: View {
    // MARK: - Properties
    let model: FeaturePortalModel

    private var inProgressFeatures: [FeatureWishResponse] {
        model.featureRequests.filter { $0.status == .inProgress }
    }

    private var upNextFeatures: [FeatureWishResponse] {
        model.featureRequests.filter { $0.status == .approved }
    }

    private var completedFeatures: [FeatureWishResponse] {
        model.featureRequests.filter { $0.status == .completed }
    }

    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(spacing: .grid(4)) {
                // Header
                VStack(spacing: .grid(2)) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.featurePortalPrimary, .featurePortalSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Product Roadmap")
                        .font(.title.bold())

                    Text("See what we're working on and what's coming next")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, .grid(4))
                .padding(.horizontal, .grid(4))

                // Roadmap Sections
                VStack(spacing: .grid(5)) {
                    // In Progress
                    RoadmapSection(
                        title: "In Progress",
                        subtitle: "We're actively building these",
                        icon: "hammer.fill",
                        color: Color.featurePortalOrange,
                        features: inProgressFeatures,
                        showPulse: true
                    )

                    // Up Next
                    RoadmapSection(
                        title: "Up Next",
                        subtitle: "Planned for future releases",
                        icon: "calendar",
                        color: Color.featurePortalPrimary,
                        features: upNextFeatures
                    )

                    // Completed
                    RoadmapSection(
                        title: "Completed",
                        subtitle: "Recently shipped features",
                        icon: "checkmark.seal.fill",
                        color: Color.featurePortalGreen,
                        features: completedFeatures
                    )
                }
                .padding(.horizontal, .grid(4))
            }
            .padding(.bottom, .grid(4))
        }
        .background(Color.featurePortalBackground)
        .navigationTitle("Roadmap")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .refreshable {
            try? await model.loadFeatureRequests()
        }
    }
}

// MARK: - Roadmap Section
private struct RoadmapSection: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let features: [FeatureWishResponse]
    var showPulse: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: .grid(3)) {
            // Section Header
            HStack(spacing: .grid(3)) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                        .symbolEffect(.pulse, isActive: showPulse)
                }

                VStack(alignment: .leading, spacing: .grid(1)) {
                    HStack(spacing: .grid(2)) {
                        Text(title)
                            .font(.title3.bold())

                        Text("\(features.count)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, .grid(2))
                            .padding(.vertical, .grid(1))
                            .background(color)
                            .clipShape(Capsule())
                    }

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            // Features
            if features.isEmpty {
                VStack(spacing: .grid(2)) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary.opacity(0.3))

                    Text("No features in this stage")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, .grid(8))
                .background(Color.featurePortalCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: .grid(3)) {
                    ForEach(features) { feature in
                        RoadmapFeatureCard(feature: feature, accentColor: color)
                    }
                }
            }
        }
        .padding(.grid(4))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.featurePortalCardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(color.opacity(0.2), lineWidth: 2)
                )
        )
    }
}

// MARK: - Roadmap Feature Card
private struct RoadmapFeatureCard: View {
    let feature: FeatureWishResponse
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: .grid(2)) {
            HStack(alignment: .top, spacing: .grid(3)) {
                VStack(alignment: .leading, spacing: .grid(2)) {
                    Text(feature.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(feature.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Vote count
                VStack(spacing: .grid(1)) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                        .foregroundStyle(accentColor)

                    Text("\(feature.upvoteCount)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accentColor)
                }
            }

            // Tags
            if !feature.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .grid(2)) {
                        ForEach(feature.tags) { tag in
                            TagView(tag: tag, size: .small)
                        }
                    }
                }
            }

            // Footer
            HStack {
                HStack(spacing: .grid(1)) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(Date(timeIntervalSince1970: feature.createdAt), style: .relative)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                if feature.commentCount > 0 {
                    HStack(spacing: .grid(1)) {
                        Image(systemName: "bubble.left.fill")
                            .font(.caption2)
                        Text("\(feature.commentCount)")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.featurePortalBlue)
                }

                Spacer()
            }
        }
        .padding(.grid(3))
        .background(Color.featurePortalCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(accentColor.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        RoadmapView(model: FeaturePortalModel(useMockData: true))
    }
}
