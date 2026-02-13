import SwiftUI

// MARK: - View Modifier

struct FeaturePromptModifier: ViewModifier {
    var message: String
    var ctaText: String
    @Binding var forceShow: Bool

    @Environment(\.scenePhase) private var scenePhase
    @State private var isPresented = false
    @State private var mascotOffset: CGFloat = 250
    @State private var mascotOpacity: Double = 0
    @State private var showSpeechBubble = false
    @State private var waveTriggered = false
    @State private var dragOffset: CGFloat = 0
    @State private var showFeatureList = false
    @State private var hasCheckedThisSession = false

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                if isPresented {
                    promptOverlay
                        .padding(.trailing, .grid(4))
                        .padding(.bottom, .grid(5))
                        .offset(y: mascotOffset + dragOffset)
                        .opacity(mascotOpacity)
                        .phaseAnimator([false, true]) { view, phase in
                            view.offset(y: isIdle ? (phase ? -3 : 3) : 0)
                        } animation: { _ in
                            .easeInOut(duration: 1.8)
                        }
                        .transition(.identity)
                        .onAppear { startEntrySequence() }
                }
            }
            .sheet(isPresented: $showFeatureList) {
                FeaturePortal.FeatureListView()
            }
            .onAppear { checkEligibility() }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    checkEligibility()
                }
            }
            .onChange(of: forceShow) { _, shouldShow in
                if shouldShow, !isPresented {
                    isPresented = true
                    forceShow = false
                }
            }
    }

    private var isIdle: Bool {
        mascotOffset == 0 && showSpeechBubble
    }

    // MARK: - Prompt Overlay

    private var promptOverlay: some View {
        VStack(alignment: .trailing, spacing: .grid(2)) {
            if showSpeechBubble {
                SpeechBubbleView(
                    message: message,
                    ctaText: ctaText,
                    onTap: { openFeatureList() },
                    onClose: { dismiss() },
                    onDontShowAgain: { optOut() }
                )
                .transition(
                    .scale(scale: 0.5, anchor: .bottomTrailing)
                    .combined(with: .opacity)
                )
            }

            MascotView(waveTriggered: waveTriggered)
                .onTapGesture { openFeatureList() }
                .gesture(dismissDragGesture)
        }
    }

    // MARK: - Drag Gesture

    private var dismissDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    dragOffset = value.translation.height * 0.6
                }
            }
            .onEnded { value in
                if value.translation.height > 60 {
                    dismiss()
                } else {
                    withAnimation(.spring(duration: 0.3)) {
                        dragOffset = 0
                    }
                }
            }
    }

    // MARK: - Actions

    private func checkEligibility() {
        guard !hasCheckedThisSession, !isPresented else { return }
        hasCheckedThisSession = true

        guard let trigger = FeaturePortal.promptTrigger,
              trigger.shouldShowPrompt() else { return }

        // Small delay so it doesn't interrupt what the user is doing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            trigger.recordPromptShown()
            isPresented = true
        }
    }

    private func openFeatureList() {
        // Happy bounce before opening
        withAnimation(.spring(duration: 0.2, bounce: 0.5)) {
            mascotOffset = -5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(duration: 0.3, bounce: 0.3)) {
                mascotOffset = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showFeatureList = true
            dismiss()
        }
    }

    private func dismiss() {
        withAnimation(.spring(duration: 0.5, bounce: 0.1)) {
            mascotOffset = 250
            mascotOpacity = 0
            showSpeechBubble = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPresented = false
        }
    }

    private func optOut() {
        FeaturePortal.promptTrigger?.userDidOptOut()
        dismiss()
    }

    // MARK: - Animation Sequence

    private func startEntrySequence() {
        // Step 1: Slide up
        withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
            mascotOffset = 0
            mascotOpacity = 1
        }

        // Step 2: Wave
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            waveTriggered.toggle()
        }

        // Step 3: Speech bubble
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                showSpeechBubble = true
            }
        }
    }
}

// MARK: - Public View Extension

public extension View {
    /// Attaches the FeaturePortal engagement prompt to this view.
    ///
    /// The prompt automatically evaluates engagement metrics and shows a friendly
    /// mascot inviting users to submit feature requests when the time is right.
    /// Tapping the prompt opens `FeatureListView` as a sheet.
    ///
    /// - Parameters:
    ///   - message: The message shown in the speech bubble. Defaults to "Help shape this app!".
    ///   - ctaText: The call-to-action button text. Defaults to "Share a Feature Request".
    ///   - forceShow: Optional binding to manually trigger the prompt, bypassing eligibility checks.
    ///     Set to `true` to show the mascot immediately. Resets to `false` after triggering.
    func featurePrompt(
        message: String = "Help shape this app!",
        ctaText: String = "Share a Feature Request",
        forceShow: Binding<Bool> = .constant(false)
    ) -> some View {
        modifier(FeaturePromptModifier(message: message, ctaText: ctaText, forceShow: forceShow))
    }
}
