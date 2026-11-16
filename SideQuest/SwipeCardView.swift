import SwiftUI

struct SwipeCardView: View {
    let event: EventItem
    var onSwipe: @MainActor @Sendable (Bool) -> Void

    @State private var offset: CGSize = .zero
    @State private var armed = false

    private let threshold: CGFloat = 110
    private let radius: CGFloat = 26

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                backgroundMedia

                LinearGradient(
                    colors: [
                        .black.opacity(0.0),
                        .black.opacity(0.30),
                        .black.opacity(0.88)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 0) {
                    topChips
                        .padding(16)

                    Spacer(minLength: 0)

                    eventDetails
                        .padding(.horizontal, 18)
                        .padding(.bottom, 20)
                        .padding(.top, 8)
                }

                stamps
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()                                               // prevent any child overflow
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
            )
            .shadow(color: Theme.cardShadow, radius: 20, x: 0, y: 10)
            .shadow(color: Theme.accent.opacity(0.12), radius: 34, x: 0, y: 18)
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

    private var backgroundMedia: some View {
        Group {
            if let localImage = ImageUtils.loadLocalImage(event.photoURL) {
                Image(uiImage: localImage)
                    .resizable()
                    .scaledToFill()
            } else if let url = URL(string: event.photoURL), !event.photoURL.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholderBackground
                    }
                }
            } else {
                placeholderBackground
            }
        }
    }

    private var placeholderBackground: some View {
        ZStack {
            LinearGradient(
                colors: [categoryColor, categoryColor.opacity(0.65), Theme.accentDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: categoryIcon)
                .font(.system(size: 140))
                .foregroundStyle(.white.opacity(0.12))
        }
    }

    private var topChips: some View {
        HStack(spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: categoryIcon)
                    .font(.caption.weight(.bold))
                Text(event.category)
                    .font(.caption.weight(.bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
            .foregroundStyle(.white)

            Spacer()

            HStack(spacing: 5) {
                Image(systemName: "calendar")
                    .font(.caption.weight(.semibold))
                Text(formattedDate)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black.opacity(0.4), in: Capsule())
            .foregroundStyle(.white)
        }
    }

    private var eventDetails: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title)
                .font(.system(size: 22, weight: .bold))
                .tracking(-0.4)
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            HStack(spacing: 5) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.teal)

                Text(event.location)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(1)
            }

            Text(event.description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.88))
                .lineSpacing(2)
                .lineLimit(3)

            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 2)

            // Host badge
            HStack(spacing: 8) {
                AvatarView(name: event.hostName, urlString: event.hostPhotoURL, size: 34)
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Hosted by \(event.hostName)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    if !event.hostMajor.isEmpty {
                        Text("\(event.hostYear) • \(event.hostMajor)")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(1)
                    }
                }

                Spacer()
            }
        }
        // Safety clamp: never let the detail block grow taller than 44% of the card
        .fixedSize(horizontal: false, vertical: false)
    }

    private var stamps: some View {
        VStack {
            HStack {
                Text("PASS")
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(Theme.rose)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Theme.rose, lineWidth: 3)
                    )
                    .rotationEffect(.degrees(-12))
                    .opacity(leftOpacity)

                Spacer()

                Text("JOIN")
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(Theme.teal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Theme.teal, lineWidth: 3)
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

    private var formattedDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(event.eventDate) {
            formatter.dateFormat = "'Today,' h:mm a"
        } else if Calendar.current.isDateInTomorrow(event.eventDate) {
            formatter.dateFormat = "'Tomorrow,' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
        }
        return formatter.string(from: event.eventDate)
    }

    private var categoryColor: Color {
        Theme.categoryColor(event.category)
    }

    private var categoryIcon: String {
        switch event.category {
        case "Study": return "book.fill"
        case "Gym": return "figure.strengthtraining.traditional"
        case "Running": return "figure.run"
        case "Coffee": return "cup.and.saucer.fill"
        case "Cowork": return "laptopcomputer"
        case "Gaming": return "gamecontroller.fill"
        case "Hackathon": return "chevron.left.forwardslash.chevron.right"
        case "Cooking": return "fork.knife"
        case "Music": return "music.note"
        case "Language exchange": return "bubble.left.and.bubble.right.fill"
        default: return "sparkles"
        }
    }
}

#Preview {
    SwipeCardView(
        event: SeedData.people[0].event,
        onSwipe: { _ in }
    )
    .padding()
    .background(Theme.surface)
}
