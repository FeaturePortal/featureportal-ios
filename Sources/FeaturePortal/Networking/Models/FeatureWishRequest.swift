import Foundation

public struct FeatureWishRequest: Codable, Sendable {
    let title: String
    let description: String
    let authorEmail: String?
}
