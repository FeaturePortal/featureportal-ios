import SwiftUI
import FeaturePortal

struct MascotPreviewScreen: View {
    @State private var triggerMascot = false
    @State private var customMessage = "Help shape this app!"
    @State private var customCTA = "Share a Feature Request"

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )

                Text("Mascot Preview")
                    .font(.title.bold())

                Text("Tap the button below to invoke the mascot animation. You can customize the message and CTA text.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(spacing: 12) {
                    TextField("Speech bubble message", text: $customMessage)
                        .textFieldStyle(.roundedBorder)

                    TextField("CTA button text", text: $customCTA)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal, 24)

                Spacer()

                Button {
                    triggerMascot = true
                } label: {
                    Text("Show Mascot")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.231, green: 0.510, blue: 0.965),
                                         Color(red: 0.549, green: 0.318, blue: 0.969)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("Mascot Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
        .featurePrompt(
            message: customMessage,
            ctaText: customCTA,
            forceShow: $triggerMascot
        )
    }
}

#Preview {
    MascotPreviewScreen()
}
