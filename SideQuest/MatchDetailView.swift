import SwiftUI
import UIKit

struct MatchDetailView: View {
    let match: MatchDoc

    @Environment(AppState.self) private var appState
    @Environment(\.openURL) private var openURL

    private var myUID: String {
        appState.myProfile?.id ?? ""
    }

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
        ScrollView {
            VStack(spacing: 24) {
                header

                if !match.sharedActivities.isEmpty {
                    sharedCard
                }

                contactCard

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Theme.surface.ignoresSafeArea())
        .navigationTitle("Match")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 12) {
            AvatarView(
                name: otherName,
                urlString: match.photo(for: otherUID),
                size: 112
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
            .shadow(color: Theme.accent.opacity(0.22), radius: 18, x: 0, y: 9)

            VStack(spacing: 6) {
                Text(otherName)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.ink)

                if !match.quest(for: otherUID).isEmpty {
                    Text("\u{201C}\(match.quest(for: otherUID))\u{201D}")
                        .font(.callout)
                        .foregroundStyle(Theme.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    private var sharedCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(title: "You're both up for")

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 90), spacing: 8)],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(match.sharedActivities, id: \.self) { activity in
                    TagChip(title: activity)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel(title: "Contact")

            if otherPhone.isEmpty {
                Text("They haven't shared a number yet.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            } else {
                Text(otherPhone)
                    .font(.title3.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Theme.ink)
                    .textSelection(.enabled)

                HStack(spacing: 8) {
                    actionButton(icon: "doc.on.doc", title: "Copy") {
                        UIPasteboard.general.string = otherPhone
                    }

                    actionButton(icon: "phone.fill", title: "Call") {
                        if let url = URL(string: "tel:\(digits)") {
                            openURL(url)
                        }
                    }

                    actionButton(icon: "message.fill", title: "Text") {
                        if let url = URL(string: "sms:\(digits)") {
                            openURL(url)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    private func actionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 52, height: 52)
                    .background(Theme.accent.opacity(0.12), in: Circle())

                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.ink)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var digits: String {
        otherPhone.filter { $0.isNumber || $0 == "+" }
    }
}
