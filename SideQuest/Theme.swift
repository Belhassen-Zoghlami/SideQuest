import SwiftUI
import UIKit

enum Theme: Sendable {
    // ── Primary brand (Electric Indigo → Violet, matched to logo) ──────────────
    static let accent     = Color(red: 0.32, green: 0.28, blue: 0.98)   // #5247FA
    static let accentDeep = Color(red: 0.18, green: 0.23, blue: 0.96)   // #2F3AFC
    static let accentSoft = Color(red: 0.62, green: 0.38, blue: 0.98)   // #9E61FB

    // ── Secondary hues (subtle, complementary) ─────────────────────────────────
    /// Warm rose-pink — used for "like" actions, match highlights, and love
    static let rose   = Color(red: 0.98, green: 0.28, blue: 0.52)       // #FA4785
    /// Muted amber-gold — timestamps, host badges, secondary info
    static let amber  = Color(red: 0.98, green: 0.68, blue: 0.22)       // #FAAD38
    /// Electric teal-cyan — location pins, cool accents, map icons
    static let teal   = Color(red: 0.22, green: 0.84, blue: 0.80)       // #38D6CC
    // Legacy alias kept for existing call-sites
    static var butter: Color { teal }

    // ── Semantic status ────────────────────────────────────────────────────────
    static let green = Color(red: 0.18, green: 0.78, blue: 0.52)
    static let red   = Color(red: 0.95, green: 0.28, blue: 0.35)

    // ── Gradients ──────────────────────────────────────────────────────────────
    static let accentGradient = LinearGradient(
        colors: [accentDeep, accentSoft],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Rose → Violet — for match moments, hearts, overlays
    static let roseGradient = LinearGradient(
        colors: [rose, accentSoft],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Teal → Indigo — for secondary CTAs, info surfaces
    static let tealGradient = LinearGradient(
        colors: [teal, accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // ── Neutrals ───────────────────────────────────────────────────────────────
    static let ink    = Color(.label)
    static let muted  = Color(.secondaryLabel)
    static let faint  = Color(.tertiaryLabel)

    // Slightly warm-tinted dark surface; cool-white light surface
    static let surface = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.07, blue: 0.12, alpha: 1)
            : UIColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1)
    })

    static let card = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.20, alpha: 1)
            : .white
    })

    static let fill = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.10)
            : UIColor(red: 0.32, green: 0.28, blue: 0.98, alpha: 0.07)
    })

    static let hairline   = Color(.separator)
    static let cardShadow = Color.black.opacity(0.10)
    static let warmShadow = Color(red: 0.32, green: 0.18, blue: 0.90).opacity(0.18)
    static let roseShadow = Color(red: 0.98, green: 0.28, blue: 0.52).opacity(0.18)

    static let corner:  CGFloat = 24
    static let control: CGFloat = 14

    // ── Category color palette (used by cards, chips, placeholders) ────────────
    static func categoryColor(_ category: String) -> Color {
        switch category {
        case "Study":            return Color(red: 0.22, green: 0.50, blue: 0.95)  // blue
        case "Gym", "Running":   return Color(red: 0.18, green: 0.80, blue: 0.48)  // green
        case "Coffee", "Cowork": return Color(red: 0.90, green: 0.55, blue: 0.20)  // amber
        case "Gaming":           return Color(red: 0.62, green: 0.28, blue: 0.98)  // violet
        case "Hackathon":        return Color(red: 0.95, green: 0.32, blue: 0.28)  // red-orange
        case "Cooking":          return Color(red: 0.96, green: 0.60, blue: 0.12)  // orange
        case "Music":            return Color(red: 0.92, green: 0.22, blue: 0.58)  // rose
        case "Language exchange": return teal
        default:                 return accent
        }
    }
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
    var category: String? = nil

    private var chipColor: Color {
        if let category {
            return Theme.categoryColor(category)
        }
        return Theme.categoryColor(title)
    }

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(chipColor.opacity(0.14), in: Capsule())
            .foregroundStyle(chipColor)
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
