import Foundation

public struct FeatureWishComment: Identifiable, Codable, Sendable {
    public let id: String
    public let body: String
    public let isByAdmin: Bool
    public let createdAt: TimeInterval
    
    public init(
        id: String = UUID().uuidString,
        body: String,
        isByAdmin: Bool = false,
        createdAt: TimeInterval = .init()
    ) {
        self.id = id
        self.body = body
        self.isByAdmin = isByAdmin
        self.createdAt = createdAt
    }
} 
