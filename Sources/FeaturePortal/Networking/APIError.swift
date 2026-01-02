import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unknown
    case invalidConfiguration
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The URL is invalid"
        case .invalidResponse:
            "The server returned an invalid response"
        case .networkError(let error):
            "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            "Failed to process the server response: \(error.localizedDescription)"
        case .serverError(let code):
            "Server error with code: \(code)"
        case .unknown:
            "An unknown error occurred"
        case .invalidConfiguration:
            "Featureloop SDK not configured. Call Featureloop.configure(apiKey:) first."
        }
    }
} 