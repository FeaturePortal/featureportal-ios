import Foundation

protocol APIClientProtocol: Actor {
    func fetchFeatureRequests() async throws -> [FeatureWishResponse]
    func submitFeatureRequest(_ request: FeatureWishRequest) async throws -> FeatureWishResponse
    func toggleVote(for requestId: String) async throws -> FeatureWishResponse
    func addComment(_ comment: CommentRequest, to requestId: String) async throws -> FeatureWishComment
    func fetchComments(for requestId: String) async throws -> [FeatureWishComment]
    func trackView(for featureWishId: String)
}

extension APIClient: APIClientProtocol {} 
