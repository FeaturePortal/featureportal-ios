import Foundation

// MARK: - Helper Types
private struct Empty: Encodable {}

// MARK: - Response Types
private struct APIResponse<T: Codable>: Codable {
    let data: T
}

actor APIClient {
    // MARK: - Properties
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var userId: String?
    
    private let userDefaults = UserDefaults.standard
    private let userIdKey = "com.featureportal.userId"
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        
        // Load userId from UserDefaults if available
        self.userId = userDefaults.string(forKey: userIdKey)
    }
    
    // MARK: - User Management
    private func ensureUserId() async throws {
        if userId == nil {
            try await createAppUser()
        }
    }
    
    private func createAppUser() async throws {
        let url = Constants.API.baseAPIURL.appending(path: "app-users")
        let appUser: AppUser = try await post(url, body: Empty())
        userId = appUser.id
        userDefaults.set(appUser.id, forKey: userIdKey)
    }
    
    // MARK: - Feature Requests
    func fetchFeatureRequests() async throws -> [FeatureWishResponse] {
        print("Starting fetchFeatureRequests")
        try await ensureUserId()
        print("UserId ensured")
        let url = Constants.API.baseAPIURL.appending(path: "feature-wishes")
        print("URL created: \(url)")
        let response: APIResponse<[FeatureWishResponse]> = try await get(url)
        print("Got response: \(response)")
        return response.data
    }
    
    func submitFeatureRequest(_ request: FeatureWishRequest) async throws -> FeatureWishResponse {
        try await ensureUserId()
        let url = Constants.API.baseAPIURL.appending(path: "feature-wishes")
        return try await post(url, body: request)
    }
    
    func toggleVote(for requestId: String) async throws -> FeatureWishResponse {
        try await ensureUserId()
        let url = Constants.API.baseAPIURL.appending(path: "feature-wishes/\(requestId)/upvote")
        return try await post(url, body: Empty())
    }
    
    func addComment(_ comment: CommentRequest, to requestId: String) async throws -> FeatureWishComment {
        try await ensureUserId()
        let url = Constants.API.baseAPIURL.appending(path: "feature-wishes/\(requestId)/comments")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(comment)
        try await addAuthHeader(to: &request)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let apiResponse = try decoder.decode(APIResponse<FeatureWishComment>.self, from: data)
        return apiResponse.data
    }
    
    func fetchComments(for requestId: String) async throws -> [FeatureWishComment] {
        try await ensureUserId()
        let url = Constants.API.baseAPIURL.appending(path: "feature-wishes/\(requestId)/comments")
        let response: APIResponse<[FeatureWishComment]> = try await get(url)
        return response.data
    }

    // MARK: - Analytics
    func trackView(for featureWishId: String) {
        // Fire and forget - don't block UI on view tracking
        Task.detached(priority: .background) { [session] in
            let apiKey = await FeaturePortal.apiKey
            guard !apiKey.isEmpty else { return }

            let url = Constants.API.baseAPIURL.appending(path: "feature-wishes/\(featureWishId)/view")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Add app user ID if available
            if let userId = await self.userId {
                request.setValue(userId, forHTTPHeaderField: "X-APP-USER-ID")
            }

            // Set source to iOS
            let body = ["source": "ios"]
            request.httpBody = try? JSONEncoder().encode(body)

            // Send request without waiting for response - silently fail if error occurs
            _ = try? await session.data(for: request)
        }
    }

    // MARK: - Private Methods
    private func addAuthHeader(to request: inout URLRequest) async throws {
        let apiKey = await FeaturePortal.apiKey
        guard !apiKey.isEmpty else {
            throw APIError.invalidConfiguration
        }
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        if let userId = userId {
            request.setValue(userId, forHTTPHeaderField: "X-APP-USER-ID")
        }
    }
    
    private func get<T: Decodable>(_ url: URL) async throws -> T {
        print("Starting GET request to \(url)")
        var request = URLRequest(url: url)
        try await addAuthHeader(to: &request)
        print("Headers added: \(request.allHTTPHeaderFields ?? [:])")
        
        let (data, response) = try await session.data(for: request)
        print("Got response with status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    private func post<T: Codable, B: Encodable>(_ url: URL, body: B) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        try await addAuthHeader(to: &request)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
            return apiResponse.data
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
}
