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
            VStack(spacing: 20) {
                eventCard

                partnerCard

                contactCard

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .background(Theme.surface.ignoresSafeArea())
        .navigationTitle("Match Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var eventCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if !match.eventCategory.isEmpty {
                    TagChip(title: match.eventCategory)
                }
                Spacer()
                Text("MATCHED EVENT")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Theme.muted)
            }

            Text(match.eventTitle.isEmpty ? "Campus Event" : match.eventTitle)
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.ink)

            if !match.quest(for: otherUID).isEmpty {
                Text(match.quest(for: otherUID))
                    .font(.body)
                    .foregroundStyle(Theme.muted)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    private var partnerCard: some View {
        HStack(spacing: 16) {
            AvatarView(
                name: otherName,
                urlString: match.photo(for: otherUID),
                size: 64
            )
            .overlay(Circle().strokeBorder(Theme.accent, lineWidth: 2))

            VStack(alignment: .leading, spacing: 3) {
                Text(otherName)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.ink)

                Text("Partner on this quest")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }

            Spacer()
        }
        .cardSurface()
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel(title: "Contact Information")

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
