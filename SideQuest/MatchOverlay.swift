import SwiftUI

struct MatchOverlay: View {
    let match: MatchDoc
    let myUID: String
    var onSeeMatches: @MainActor @Sendable () -> Void
    var onDismiss: @MainActor @Sendable () -> Void

    @Environment(\.openURL) private var openURL
    @State private var alertMessage: String?
    @State private var showAlert = false

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
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Theme.rose)

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
                        Theme.roseGradient,
                        lineWidth: 4
                    )
                )
                .shadow(color: Theme.rose.opacity(0.3), radius: 18, x: 0, y: 10)
                .padding(.top, 2)

                VStack(spacing: 3) {
                    Text("Host: \(otherName)")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    if !match.eventCategory.isEmpty {
                        TagChip(title: match.eventCategory)
                    }
                }

                if !hasValidPhone {
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
                            handleCopy()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Call") {
                            handleCall()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Text") {
                            handleText()
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
            .alert("Contact Host", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage ?? "")
            }
        }
        .transition(.opacity)
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
            alertMessage = "Host has not shared a valid phone number."
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
            alertMessage = "Host has not shared a valid phone number."
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
