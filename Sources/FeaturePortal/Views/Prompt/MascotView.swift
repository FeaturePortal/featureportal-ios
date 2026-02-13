import SwiftUI

// MARK: - Lightbulb Shape

struct LightbulbShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        let neckWidth = w * 0.38
        let neckLeft = (w - neckWidth) / 2
        let neckRight = neckLeft + neckWidth
        let neckTop = h * 0.65

        path.move(to: CGPoint(x: neckLeft, y: h))
        path.addLine(to: CGPoint(x: neckLeft, y: neckTop))

        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.35),
            control1: CGPoint(x: neckLeft - w * 0.05, y: neckTop - h * 0.05),
            control2: CGPoint(x: 0, y: h * 0.50)
        )

        path.addArc(
            center: CGPoint(x: w / 2, y: h * 0.35),
            radius: w / 2,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )

        path.addCurve(
            to: CGPoint(x: neckRight, y: neckTop),
            control1: CGPoint(x: w, y: h * 0.50),
            control2: CGPoint(x: neckRight + w * 0.05, y: neckTop - h * 0.05)
        )

        path.addLine(to: CGPoint(x: neckRight, y: h))
        path.closeSubpath()
        return path
    }
}

// MARK: - Mascot View

struct MascotView: View {
    var waveTriggered: Bool

    private let bulbSize: CGFloat = 55
    private let bulbHeight: CGFloat = 60

    var body: some View {
        ZStack {
            glowEffect
            bulbBody
        }
        .frame(width: 100, height: 90)
    }

    // MARK: - Glow

    private var glowEffect: some View {
        ZStack {
            Circle()
                .fill(Color.featurePortalOrange.opacity(0.08))
                .frame(width: 90, height: 90)
                .blur(radius: 25)
            Circle()
                .fill(Color.featurePortalOrange.opacity(0.15))
                .frame(width: 65, height: 65)
                .blur(radius: 15)
            Circle()
                .fill(Color.featurePortalOrange.opacity(0.3))
                .frame(width: 45, height: 45)
                .blur(radius: 8)
        }
        .offset(y: -8)
    }

    // MARK: - Bulb Body

    private var bulbBody: some View {
        VStack(spacing: 1) {
            ZStack {
                // Bulb shape
                LightbulbShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.featurePortalOrange,
                                Color.featurePortalOrange.opacity(0.85),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: bulbSize, height: bulbHeight)

                // Face
                faceView
                    .offset(y: -bulbHeight * 0.12)

                // Arms
                armLeft
                armRight
            }

            // Screw base
            screwBase
        }
    }

    // MARK: - Face

    private var faceView: some View {
        VStack(spacing: 4) {
            // Eyes
            HStack(spacing: 14) {
                eyeView
                eyeView
            }

            // Smile
            SmileShape()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 14, height: 6)
        }
    }

    private var eyeView: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
            Circle()
                .fill(Color(white: 0.25))
                .frame(width: 4, height: 4)
                .offset(x: 0.5, y: -0.5)
        }
    }

    // MARK: - Arms

    private var armLeft: some View {
        Capsule()
            .fill(Color.featurePortalOrange.opacity(0.9))
            .frame(width: 18, height: 5)
            .rotationEffect(.degrees(-25), anchor: .trailing)
            .offset(x: -bulbSize / 2 - 4, y: 4)
    }

    private var armRight: some View {
        HStack(spacing: 0) {
            Capsule()
                .fill(Color.featurePortalOrange.opacity(0.9))
                .frame(width: 18, height: 5)
            Circle()
                .fill(Color.featurePortalOrange.opacity(0.9))
                .frame(width: 6, height: 6)
                .offset(x: -2)
        }
        .keyframeAnimator(
            initialValue: WaveKeyframes(),
            trigger: waveTriggered
        ) { content, value in
            content
                .rotationEffect(.degrees(value.rotation), anchor: .leading)
        } keyframes: { _ in
            KeyframeTrack(\.rotation) {
                SpringKeyframe(-35.0, duration: 0.15, spring: .snappy)
                SpringKeyframe(20.0, duration: 0.15, spring: .snappy)
                SpringKeyframe(-35.0, duration: 0.15, spring: .snappy)
                SpringKeyframe(20.0, duration: 0.15, spring: .snappy)
                SpringKeyframe(-35.0, duration: 0.15, spring: .snappy)
                SpringKeyframe(0.0, duration: 0.25, spring: .smooth)
            }
        }
        .offset(x: bulbSize / 2 + 4, y: 4)
    }

    // MARK: - Screw Base

    private var screwBase: some View {
        VStack(spacing: 2) {
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 26, height: 4)
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 22, height: 4)
            Capsule()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 18, height: 4)
        }
    }
}

// MARK: - Supporting Types

private struct WaveKeyframes {
    var rotation: Double = 0.0
}

private struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: 0),
            control: CGPoint(x: rect.width / 2, y: rect.height)
        )
        return path
    }
}
