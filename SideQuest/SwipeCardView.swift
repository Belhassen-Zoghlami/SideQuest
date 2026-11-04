import SwiftUI

struct SwipeCardView: View {
    let student: Student
    var onSwipe: @MainActor @Sendable (Bool) -> Void

    @State private var offset: CGSize = .zero
    @State private var armed = false

    private let threshold: CGFloat = 110
    private let radius: CGFloat = 26

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                photo

                LinearGradient(
                    colors: [.clear, .black.opacity(0.08), .black.opacity(0.82)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                details
                    .padding(22)

                stamps
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(Theme.muted.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
            )
            .shadow(color: Theme.cardShadow, radius: 20, x: 0, y: 10)
            .shadow(color: Theme.accent.opacity(0.10), radius: 34, x: 0, y: 18)
            .offset(x: offset.width, y: offset.height * 0.25)
            .rotationEffect(.degrees(Double(offset.width / 22)))
            .animation(.spring(response: 0.34, dampingFraction: 0.78), value: offset)
            .gesture(dragGesture)
            .sensoryFeedback(.impact(weight: .light), trigger: armed)
        }
        .padding(.horizontal, 4)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
                let nowArmed = abs(value.translation.width) > threshold
                if nowArmed != armed {
                    armed = nowArmed
                }
            }
            .onEnded { value in
                let horizontal = value.translation.width

                if abs(horizontal) > threshold {
                    let liked = horizontal > 0
                    withAnimation(.easeOut(duration: 0.22)) {
                        offset = CGSize(width: liked ? 900 : -900, height: value.translation.height)
                    }
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.22))
                        onSwipe(liked)
                    }
                } else {
                    offset = .zero
                }
            }
    }

    private var photo: some View {
        Group {
            if let url = URL(string: student.photoURL), !student.photoURL.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        photoPlaceholder
                    }
                }
            } else {
                photoPlaceholder
            }
        }
    }

    private var photoPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.accent, Theme.accentSoft],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(initials)
                .font(.system(size: 108, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(student.displayName)
                .font(.system(size: 32, weight: .bold))
                .tracking(-0.5)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text("\(student.year) · \(student.major)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)

            Text(student.quest)
                .font(.callout)
                .foregroundStyle(.white.opacity(0.95))
                .lineSpacing(2)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)

            if !student.activities.isEmpty {
                HStack(spacing: 6) {
                    ForEach(student.activities.prefix(3), id: \.self) { activity in
                        Text(activity)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.18), in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.18), lineWidth: 0.5))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private var stamps: some View {
        VStack {
            HStack {
                Text("NOPE")
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(Theme.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Theme.red, lineWidth: 3)
                    )
                    .rotationEffect(.degrees(-12))
                    .opacity(leftOpacity)

                Spacer()

                Text("IN")
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(Theme.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Theme.green, lineWidth: 3)
                    )
                    .rotationEffect(.degrees(12))
                    .opacity(rightOpacity)
            }
            .padding(24)

            Spacer()
        }
    }

    private var leftOpacity: Double {
        Double(max(0, -offset.width / 120))
    }

    private var rightOpacity: Double {
        Double(max(0, offset.width / 120))
    }

    private var initials: String {
        let parts = student.displayName.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map { String($0) }.joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }
}
