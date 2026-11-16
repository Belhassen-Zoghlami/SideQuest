import SwiftUI
import UIKit

struct MatchDetailView: View {
    let match: MatchDoc

    @Environment(AppState.self) private var appState
    @Environment(\.openURL) private var openURL
    @State private var alertMessage: String?
    @State private var showAlert = false

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

            if !hasValidPhone {
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
                        handleCopy()
                    }

                    actionButton(icon: "phone.fill", title: "Call") {
                        handleCall()
                    }

                    actionButton(icon: "message.fill", title: "Text") {
                        handleText()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .alert("Contact", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
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
        let raw = otherPhone.filter { $0.isNumber || $0 == "+" }
        if raw.hasPrefix("+1555") && raw.count == 9 {
            return "+1555010" + String(raw.suffix(4))
        }
        return raw
    }

    private var hasValidPhone: Bool {
        let numericOnly = digits.filter { $0.isNumber }
        return numericOnly.count >= 7
    }

    private func handleCall() {
        guard hasValidPhone else {
            alertMessage = "No valid phone number available to call."
            showAlert = true
            return
        }

        let phoneDigits = digits
        if let promptURL = URL(string: "telprompt:\(phoneDigits)"), UIApplication.shared.canOpenURL(promptURL) {
            UIApplication.shared.open(promptURL)
        } else if let telURL = URL(string: "tel:\(phoneDigits)"), UIApplication.shared.canOpenURL(telURL) {
            UIApplication.shared.open(telURL)
        } else {
            UIPasteboard.general.string = otherPhone
            alertMessage = "Calling is not supported on this device/simulator. The phone number (\(otherPhone)) has been copied to your clipboard."
            showAlert = true
        }
    }

    private func handleText() {
        guard hasValidPhone else {
            alertMessage = "No valid phone number available to message."
            showAlert = true
            return
        }

        let phoneDigits = digits
        if let smsURL = URL(string: "sms:\(phoneDigits)"), UIApplication.shared.canOpenURL(smsURL) {
            UIApplication.shared.open(smsURL)
        } else {
            UIPasteboard.general.string = otherPhone
            alertMessage = "Messaging is not supported on this device/simulator. The phone number (\(otherPhone)) has been copied to your clipboard."
            showAlert = true
        }
    }

    private func handleCopy() {
        UIPasteboard.general.string = otherPhone
        alertMessage = "Phone number copied to clipboard!"
        showAlert = true
    }
}
