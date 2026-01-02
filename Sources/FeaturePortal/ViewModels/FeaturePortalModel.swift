import SwiftUI

public enum SortOption: String, CaseIterable {
    case newest = "Newest"
    case topVoted = "Top Voted"

    func sort(_ requests: [FeatureWishResponse]) -> [FeatureWishResponse] {
        switch self {
        case .newest:
            return requests.sorted { $0.createdAt > $1.createdAt }
        case .topVoted:
            return requests.sorted { $0.upvoteCount > $1.upvoteCount }
        }
    }
}

@Observable
@MainActor
public final class FeaturePortalModel {
    // MARK: - Properties
    private var allFeatureRequests: [FeatureWishResponse] = []
    private(set) var featureRequests: [FeatureWishResponse] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    var sortOption: SortOption = .newest {
        didSet {
            applyFiltersAndSort()
        }
    }

    var selectedTags: Set<String> = [] {
        didSet {
            applyFiltersAndSort()
        }
    }

    var searchText: String = "" {
        didSet {
            applyFiltersAndSort()
        }
    }

    var availableTags: [Tag] {
        let allTags = allFeatureRequests.flatMap { $0.tags }
        var uniqueTags: [Tag] = []
        var seenIds = Set<String>()

        for tag in allTags {
            if !seenIds.contains(tag.id) {
                seenIds.insert(tag.id)
                uniqueTags.append(tag)
            }
        }

        return uniqueTags.sorted { $0.name < $1.name }
    }

    private let api: APIClientProtocol

    // MARK: - Vote Undo Configuration
    private let voteUndoTimeWindow: TimeInterval = 300 // 5 minutes
    private let voteTimestampsKey = "com.featureportal.voteTimestamps"

    private var voteTimestamps: [String: Date] {
        get {
            guard let data = UserDefaults.standard.data(forKey: voteTimestampsKey),
                  let timestamps = try? JSONDecoder().decode([String: Date].self, from: data) else {
                return [:]
            }
            return timestamps
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: voteTimestampsKey)
            }
        }
    }
    
    // MARK: - Initialization
    public init(useMockData: Bool = false) {
        self.api = useMockData ? MockAPIClient() : APIClient()
        
        // Load initial data
        Task {
            try? await loadFeatureRequests()
        }
    }
    
    // MARK: - Public Methods
    public func submitFeatureRequest(_ request: FeatureWishRequest) async throws {
        isLoading = true
        defer { isLoading = false }

        let newRequest = try await api.submitFeatureRequest(request)

        // Automatically upvote the newly created request
        let upvotedRequest = try await api.toggleVote(for: newRequest.id)

        // Track vote timestamp
        var timestamps = voteTimestamps
        timestamps[upvotedRequest.id] = Date()
        voteTimestamps = timestamps

        allFeatureRequests.append(upvotedRequest)
        applyFiltersAndSort()
    }
    
    public func canUndoVote(for request: FeatureWishResponse) -> Bool {
        guard request.upvotedByCurrentUser,
              let voteTime = voteTimestamps[request.id] else {
            return false
        }

        let elapsed = Date().timeIntervalSince(voteTime)
        return elapsed < voteUndoTimeWindow
    }

    public func remainingUndoTime(for request: FeatureWishResponse) -> TimeInterval? {
        guard request.upvotedByCurrentUser,
              let voteTime = voteTimestamps[request.id] else {
            return nil
        }

        let elapsed = Date().timeIntervalSince(voteTime)
        let remaining = voteUndoTimeWindow - elapsed
        return remaining > 0 ? remaining : nil
    }

    public func toggleVote(for request: FeatureWishResponse) async throws {
        isLoading = true
        defer { isLoading = false }

        let updatedRequest = try await api.toggleVote(for: request.id)

        // Track vote timestamp when voting (not unvoting)
        if updatedRequest.upvotedByCurrentUser {
            var timestamps = voteTimestamps
            timestamps[request.id] = Date()
            voteTimestamps = timestamps
        } else {
            // Remove timestamp when unvoting
            var timestamps = voteTimestamps
            timestamps.removeValue(forKey: request.id)
            voteTimestamps = timestamps
        }

        // Update the request in the main array
        if let index = allFeatureRequests.firstIndex(where: { $0.id == request.id }) {
            allFeatureRequests[index] = updatedRequest
        }
        applyFiltersAndSort()
    }
    
    public func addComment(_ comment: String, to request: FeatureWishResponse) async throws -> FeatureWishComment {
        let commentRequest = CommentRequest(body: comment)
        return try await api.addComment(commentRequest, to: request.id)
    }
    
    public func loadFeatureRequests() async throws {
        isLoading = true
        defer { isLoading = false }

        allFeatureRequests = try await api.fetchFeatureRequests()
        applyFiltersAndSort()
    }

    private func applyFiltersAndSort() {
        var filtered = allFeatureRequests

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply tag filter
        if !selectedTags.isEmpty {
            filtered = filtered.filter { request in
                request.tags.contains { tag in
                    selectedTags.contains(tag.id)
                }
            }
        }

        // Apply sort
        featureRequests = sortOption.sort(filtered)
    }
    
    public func fetchComments(for request: FeatureWishResponse) async throws -> [FeatureWishComment] {
        isLoading = true
        defer { isLoading = false }

        return try await api.fetchComments(for: request.id)
    }

    public func trackView(for request: FeatureWishResponse) {
        Task {
            await api.trackView(for: request.id)
        }
    }
} 
