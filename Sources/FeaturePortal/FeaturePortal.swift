import SwiftUI

@MainActor
public final class FeaturePortal {
    // MARK: - Properties
    static var apiKey = ""

    // MARK: - Configuration
    public static func configure(apiKey: String) {
        self.apiKey = apiKey
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
