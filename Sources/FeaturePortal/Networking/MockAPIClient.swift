import Foundation

actor MockAPIClient: APIClientProtocol {
    private var featureRequests: [FeatureWishResponse] = [
        FeatureWishResponse(
            title: "Dark Mode Support",
            description: "Add support for dark mode throughout the application for better visibility in low-light conditions.",
            upvoteCount: 42,
            commentCount: 2,
            upvotedByCurrentUser: true,
            tags: [
                Tag(name: "UI", color: .blue),
                Tag(name: "Enhancement", color: .green)
            ],
            status: .inProgress
        ),
        FeatureWishResponse(
            title: "Offline Mode",
            description: "Allow users to continue working when internet connection is unavailable.",
            upvoteCount: 28,
            commentCount: 0,
            upvotedByCurrentUser: false,
            tags: [
                Tag(name: "Feature", color: .purple)
            ],
            status: .approved
        ),
        FeatureWishResponse(
            title: "Export to PDF",
            description: "Add the ability to export data to PDF format for easy sharing and printing.",
            upvoteCount: 15,
            commentCount: 0,
            upvotedByCurrentUser: true,
            tags: [
                Tag(name: "Export", color: .orange),
                Tag(name: "Feature", color: .purple)
            ],
            status: .completed
        ),
        FeatureWishResponse(
            title: "Custom Themes",
            description: "Allow users to customize the app's color scheme and theme.",
            upvoteCount: 35,
            commentCount: 1,
            upvotedByCurrentUser: false,
            tags: [
                Tag(name: "UI", color: .blue)
            ],
            status: .approved
        ),
        FeatureWishResponse(
            title: "Push Notifications",
            description: "Send push notifications for important updates and reminders.",
            upvoteCount: 22,
            commentCount: 0,
            upvotedByCurrentUser: false,
            tags: [
                Tag(name: "Feature", color: .purple)
            ],
            status: .pending
        )
    ]
    
    private var mockComments: [String: [FeatureWishComment]] = [:]
    
    func fetchFeatureRequests() async throws -> [FeatureWishResponse] {
        featureRequests
    }
    
    func submitFeatureRequest(_ input: FeatureWishRequest) async throws -> FeatureWishResponse {
        let newRequest = FeatureWishResponse(
            title: input.title,
            description: input.description,
            upvoteCount: 0,
            commentCount: 0,
            createdAt: .init(),
            upvotedByCurrentUser: false
        )
        featureRequests.append(newRequest)
        return newRequest
    }
    
    func toggleVote(for requestId: String) async throws -> FeatureWishResponse {
        guard let index = featureRequests.firstIndex(where: { $0.id == requestId }) else {
            throw APIError.invalidResponse
        }
        
        let request = featureRequests[index]
        let newRequest = FeatureWishResponse(
            id: request.id,
            title: request.title,
            description: request.description,
            upvoteCount: request.upvotedByCurrentUser ? request.upvoteCount - 1 : request.upvoteCount + 1,
            commentCount: request.commentCount,
            createdAt: .init(),
            upvotedByCurrentUser: !request.upvotedByCurrentUser,
            tags: request.tags,
            status: request.status
        )
        
        featureRequests[index] = newRequest
        return newRequest
    }
    
    func addComment(_ comment: CommentRequest, to requestId: String) async throws -> FeatureWishComment {
        let newComment = FeatureWishComment(
            body: comment.body,
            isByAdmin: false,
            createdAt: Date().timeIntervalSince1970
        )
        
        // Update the mock comments array if needed
        var comments = mockComments[requestId] ?? []
        comments.append(newComment)
        mockComments[requestId] = comments
        
        return newComment
    }
    
    func fetchComments(for requestId: String) async throws -> [FeatureWishComment] {
        return mockComments[requestId] ?? []
    }

    func trackView(for featureWishId: String) {
        // Mock implementation - no-op
    }
} 
