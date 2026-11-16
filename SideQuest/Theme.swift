import SwiftUI
import UIKit

enum Theme: Sendable {
    // Primary brand colors matched to the logo (Electric Blue -> Indigo -> Purple)
    static let accent = Color(red: 0.32, green: 0.28, blue: 0.98)        // #5247FA - Vibrant Electric Indigo
    static let accentDeep = Color(red: 0.18, green: 0.23, blue: 0.96)    // #2F3AFC - Electric Royal Blue
    static let accentSoft = Color(red: 0.62, green: 0.38, blue: 0.98)    // #9E61FB - Electric Violet / Orchid
    static let butter = Color(red: 0.25, green: 0.85, blue: 0.82)        // #40D9D1 - Electric Cyan Highlight
    static let green = Color(red: 0.18, green: 0.78, blue: 0.52)
    static let red = Color(red: 0.95, green: 0.28, blue: 0.35)

    static let accentGradient = LinearGradient(
        colors: [
            Color(red: 0.18, green: 0.23, blue: 0.96),
            Color(red: 0.60, green: 0.36, blue: 0.98)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ink = Color(.label)
    static let muted = Color(.secondaryLabel)
    static let faint = Color(.tertiaryLabel)

    static let surface = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1)
            : UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1)
    })

    static let card = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.13, green: 0.13, blue: 0.19, alpha: 1)
            : .white
    })

    static let fill = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.10)
            : UIColor(red: 0.35, green: 0.32, blue: 0.50, alpha: 0.08)
    })

    static let hairline = Color(.separator)

    static let cardShadow = Color.black.opacity(0.10)
    static let warmShadow = Color(red: 0.25, green: 0.22, blue: 0.85).opacity(0.18)
    static let corner: CGFloat = 24
    static let control: CGFloat = 14
}

extension View {
    func cardSurface(padding: CGFloat = 18, radius: CGFloat = 18) -> some View {
        self
            .padding(padding)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    func screenBackground() -> some View {
        self.background(Theme.surface.ignoresSafeArea())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var enabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(enabled ? Color.white : Theme.muted)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                if enabled {
                    RoundedRectangle(cornerRadius: Theme.control, style: .continuous)
                        .fill(Theme.accentGradient)
                        .shadow(color: Theme.accent.opacity(0.30), radius: 14, x: 0, y: 7)
                } else {
                    RoundedRectangle(cornerRadius: Theme.control, style: .continuous)
                        .fill(Theme.fill)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Theme.fill)
            .clipShape(RoundedRectangle(cornerRadius: Theme.control, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct CircleIconButtonStyle: ButtonStyle {
    var diameter: CGFloat = 62

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: diameter, height: diameter)
            .background(Theme.card, in: Circle())
            .shadow(color: Theme.warmShadow, radius: 14, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ActivityChip: View {
    let title: String
    var selected: Bool = false

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background {
                if selected {
                    Capsule().fill(Theme.accentGradient)
                } else {
                    Capsule().fill(Theme.fill)
                }
            }
            .foregroundStyle(selected ? Color.white : Theme.ink)
            .animation(.easeOut(duration: 0.15), value: selected)
    }
}

struct TagChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.accent.opacity(0.12), in: Capsule())
            .foregroundStyle(Theme.accent)
    }
}

struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(0.6)
            .foregroundStyle(Theme.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
