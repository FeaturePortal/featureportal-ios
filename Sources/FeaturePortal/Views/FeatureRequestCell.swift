import SwiftUI

struct FeatureRequestCell: View {
    // MARK: - Properties
    let model: FeaturePortalModel
    let request: FeatureWishResponse
    let onVote: () -> Void

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: .grid(3)) {
            // Title and Vote Button
            HStack(alignment: .top, spacing: .grid(3)) {
                VStack(alignment: .leading, spacing: .grid(2)) {
                    Text(request.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text(request.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }

                Spacer()

                VoteButton(
                    votes: request.upvoteCount,
                    isVoted: request.upvotedByCurrentUser,
                    onVote: onVote
                )
            }

            // Tags
            if !request.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .grid(2)) {
                        ForEach(request.tags) { tag in
                            TagView(tag: tag, size: .small)
                        }
                    }
                }
            }

            // Footer with metadata
            HStack(spacing: .grid(4)) {
                HStack(spacing: .grid(1)) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(Date(timeIntervalSince1970: request.createdAt), style: .relative)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                if request.commentCount > 0 {
                    HStack(spacing: .grid(1)) {
                        Image(systemName: "bubble.left.fill")
                            .font(.caption)
                        Text("\(request.commentCount)")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(Color.featurePortalBlue)
                    .padding(.horizontal, .grid(2))
                    .padding(.vertical, .grid(1))
                    .background(Color.featurePortalBlue.opacity(0.1))
                    .clipShape(Capsule())
                }

                Spacer()
            }
        }
        .padding(.grid(4))
        .background(Color.featurePortalCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.featurePortalBorder.opacity(0.5), lineWidth: 0.5)
        )
    }
}

// MARK: - VoteButton
struct VoteButton: View {
    let votes: Int
    let isVoted: Bool
    let onVote: () -> Void

    var body: some View {
        Button(action: onVote) {
            VStack(spacing: .grid(1)) {
                Image(systemName: isVoted ? "arrow.up.circle.fill" : "arrow.up.circle")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 24, height: 24)

                Text("\(votes)")
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
            }
            .foregroundStyle(isVoted ? Color.featurePortalOrange : .secondary)
            .frame(minWidth: 44)
            .padding(.horizontal, .grid(2))
            .padding(.vertical, .grid(2))
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isVoted ? Color.featurePortalOrange.opacity(0.12) : Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isVoted ? Color.featurePortalOrange.opacity(0.3) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let sampleRequest = FeatureWishResponse(
        title: "Dark Mode Support",
        description: "Add support for dark mode throughout the application",
        upvoteCount: 42,
        commentCount: 0,
        upvotedByCurrentUser: true
    )
    
    FeatureRequestCell(
        model: FeaturePortalModel(),
        request: sampleRequest,
        onVote: {}
    )
    .padding()
} 
