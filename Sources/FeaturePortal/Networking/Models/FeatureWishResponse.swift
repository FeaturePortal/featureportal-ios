import Foundation

public enum FeatureStatus: String, Codable, CaseIterable, Sendable {
    case pending = "pending"
    case approved = "approved"
    case inProgress = "in_progress"
    case completed = "completed"
    case rejected = "rejected"

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Up Next"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .rejected: return "Rejected"
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .approved: return "checkmark.circle"
        case .inProgress: return "hammer"
        case .completed: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle"
        }
    }
}

public struct FeatureWishResponse: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let upvoteCount: Int
    public let commentCount: Int
    public let createdAt: TimeInterval
    public let upvotedByCurrentUser: Bool
    public var tags: [Tag]
    public var status: FeatureStatus

    enum CodingKeys: String, CodingKey {
        case id, title, description, upvoteCount, commentCount, createdAt, upvotedByCurrentUser, tags, status
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        upvoteCount = try container.decode(Int.self, forKey: .upvoteCount)
        commentCount = try container.decode(Int.self, forKey: .commentCount)
        createdAt = try container.decode(TimeInterval.self, forKey: .createdAt)
        upvotedByCurrentUser = try container.decode(Bool.self, forKey: .upvotedByCurrentUser)
        tags = try container.decodeIfPresent([Tag].self, forKey: .tags) ?? []
        status = try container.decodeIfPresent(FeatureStatus.self, forKey: .status) ?? .pending
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(upvoteCount, forKey: .upvoteCount)
        try container.encode(commentCount, forKey: .commentCount)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(upvotedByCurrentUser, forKey: .upvotedByCurrentUser)
        try container.encode(tags, forKey: .tags)
        try container.encode(status, forKey: .status)
    }

    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        upvoteCount: Int = 0,
        commentCount: Int = 0,
        createdAt: TimeInterval = .init(),
        upvotedByCurrentUser: Bool = false,
        tags: [Tag] = [],
        status: FeatureStatus = .pending
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.upvoteCount = upvoteCount
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.upvotedByCurrentUser = upvotedByCurrentUser
        self.tags = tags
        self.status = status
    }
} 
