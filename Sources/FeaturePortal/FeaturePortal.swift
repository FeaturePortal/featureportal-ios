import SwiftUI

@MainActor
public final class FeaturePortal {
    // MARK: - Properties
    static var apiKey = ""

    /// Shared prompt trigger instance, created during `configure()`.
    public private(set) static var promptTrigger: FeaturePromptTrigger?

    // MARK: - Configuration

    /// Configure the SDK with your API key and optional prompt configuration.
    ///
    /// - Parameters:
    ///   - apiKey: Your FeaturePortal API key.
    ///   - promptConfiguration: Custom engagement thresholds for the feature prompt.
    ///     Pass `nil` to disable the engagement prompt entirely.
    public static func configure(
        apiKey: String,
        promptConfiguration: FeaturePromptConfiguration? = FeaturePromptConfiguration()
    ) {
        self.apiKey = apiKey
        if let config = promptConfiguration {
            self.promptTrigger = FeaturePromptTrigger(configuration: config)
        } else {
            self.promptTrigger = nil
        }
    }

    /// Convenience: log an app launch event for engagement tracking.
    public static func logAppLaunch() {
        promptTrigger?.logAppLaunch()
    }

    /// Convenience: log a significant event for engagement tracking.
    public static func logSignificantEvent() {
        promptTrigger?.logSignificantEvent()
    }
    
    // MARK: - View Factory
    public struct FeatureListView: View {
        @State private var model = FeaturePortalModel()

        public init() {}

        public var body: some View {
            #if os(macOS) || os(visionOS)
            // TODO: macOS and visionOS support
            Text("FeaturePortal is currently only supported on iOS")
            #else
            TabView {
                FeatureRequestList(model: model)
                    .tabItem {
                        Label("Requests", systemImage: "lightbulb.fill")
                    }

                RoadmapView(model: model)
                    .tabItem {
                        Label("Roadmap", systemImage: "map.fill")
                    }
            }
            #endif
        }
    }

    // MARK: - Private Init
    private init() {}
}
