import Foundation
import SwiftUI

public struct Tag: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let color: TagColorType

    public init(id: String = UUID().uuidString, name: String, color: TagColorType) {
        self.id = id
        self.name = name
        self.color = color
    }
}

public enum TagColorType: String, Codable, CaseIterable, Sendable {
    case blue = "blue"
    case red = "red"
    case green = "green"
    case purple = "purple"
    case orange = "orange"

    public var color: Color {
        switch self {
        case .blue: return .featurePortalBlue
        case .red: return .featurePortalRed
        case .green: return .featurePortalGreen
        case .purple: return .featurePortalPurple
        case .orange: return .featurePortalOrange
        }
    }

    public var lightColor: Color {
        color.opacity(0.15)
    }
}
