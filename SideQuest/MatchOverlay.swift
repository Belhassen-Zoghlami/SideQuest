import SwiftUI

struct MatchOverlay: View {
    let match: MatchDoc
    let myUID: String
    var onSeeMatches: @MainActor @Sendable () -> Void
    var onDismiss: @MainActor @Sendable () -> Void

    @Environment(\.openURL) private var openURL

    private var otherUID: String {
        match.otherUID(for: myUID)
    }

    private var otherName: String {
        match.name(for: otherUID)
    }

    private var otherPhone: String {
        match.phone(for: otherUID)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            Color.black.opacity(0.18)
                .ignoresSafeArea()

            Theme.accentDeep.opacity(0.12)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.butter)

                    Text("You're In!")
                        .font(.system(size: 32, weight: .bold))
                        .tracking(-0.6)
                        .foregroundStyle(Theme.ink)

                    Text("You joined **\(match.eventTitle.isEmpty ? otherName + "'s Event" : match.eventTitle)**")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                AvatarView(
                    name: otherName,
                    urlString: match.photo(for: otherUID),
                    size: 96
                )
                .overlay(
                    Circle().strokeBorder(
                        LinearGradient(
                            colors: [Theme.accent, Theme.butter],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                )
                .shadow(color: Theme.accent.opacity(0.25), radius: 18, x: 0, y: 10)
                .padding(.top, 2)

                VStack(spacing: 3) {
                    Text("Host: \(otherName)")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    if !match.eventCategory.isEmpty {
                        TagChip(title: match.eventCategory)
                    }
                }

                if otherPhone.isEmpty {
                    Text("Host has not shared a direct phone number.")
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                } else {
                    VStack(spacing: 4) {
                        Text("HOST CONTACT")
                            .font(.caption2.weight(.semibold))
                            .tracking(0.6)
                            .foregroundStyle(Theme.muted)

                        Text(otherPhone)
                            .font(.title3.weight(.bold).monospacedDigit())
                            .foregroundStyle(Theme.ink)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.control, style: .continuous))

                    HStack(spacing: 10) {
                        Button("Copy") {
                            UIPasteboard.general.string = otherPhone
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Call") {
                            if let url = URL(string: "tel:\(digits)") {
                                openURL(url)
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Text") {
                            if let url = URL(string: "sms:\(digits)") {
                                openURL(url)
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }

                Button("See all matches") {
                    onSeeMatches()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 6)

                Button("Keep swiping") {
                    onDismiss()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.muted)
                .padding(.top, 2)
            }
            .padding(24)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 30, x: 0, y: 18)
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
    }

    private var digits: String {
        otherPhone.filter { $0.isNumber || $0 == "+" }
    }
}
