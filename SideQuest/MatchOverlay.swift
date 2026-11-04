import SwiftUI
import UIKit

struct MatchOverlay: View {
    let match: MatchDoc
    let myUID: String
    var onSeeMatches: @MainActor @Sendable () -> Void
    var onDismiss: @MainActor @Sendable () -> Void

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

            Color.black.opacity(0.10)
                .ignoresSafeArea()

            Theme.accentDeep.opacity(0.12)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                VStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.butter)
                        .padding(.bottom, 2)

                    Text("It's a match")
                        .font(.system(size: 30, weight: .bold))
                        .tracking(-0.6)
                        .foregroundStyle(Theme.ink)

                    Text("You and \(otherName) both swiped right.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                        .multilineTextAlignment(.center)
                }

                AvatarView(
                    name: otherName,
                    urlString: match.photo(for: otherUID),
                    size: 104
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
                .padding(.top, 4)

                if !match.sharedActivities.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(match.sharedActivities.prefix(3), id: \.self) { activity in
                            TagChip(title: activity)
                        }
                    }
                }

                if !match.quest(for: otherUID).isEmpty {
                    Text("\u{201C}\(match.quest(for: otherUID))\u{201D}")
                        .font(.callout)
                        .foregroundStyle(Theme.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 4)
                }

                if otherPhone.isEmpty {
                    Text("They haven't shared a number yet.")
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                } else {
                    VStack(spacing: 4) {
                        Text("THEIR NUMBER")
                            .font(.caption2.weight(.semibold))
                            .tracking(0.6)
                            .foregroundStyle(Theme.muted)

                        Text(otherPhone)
                            .font(.title3.weight(.semibold).monospacedDigit())
                            .foregroundStyle(Theme.ink)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.control, style: .continuous))

                    HStack(spacing: 10) {
                        Button("Copy") {
                            UIPasteboard.general.string = otherPhone
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Call") {
                            open("tel:\(digits)")
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Text") {
                            open("sms:\(digits)")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }

                Button("See all matches") {
                    onSeeMatches()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 4)

                Button("Keep swiping") {
                    onDismiss()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.muted)
                .padding(.top, 2)
            }
            .padding(24)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.22), radius: 30, x: 0, y: 18)
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
    }

    private var digits: String {
        otherPhone.filter { $0.isNumber || $0 == "+" }
    }

    private func open(_ string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
    }
}
