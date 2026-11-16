import SwiftUI

struct AvatarView: View {
    let name: String
    let urlString: String
    var image: UIImage? = nil
    var size: CGFloat = 56

    var body: some View {
        content
            .frame(width: size, height: size)   // hard static frame — always enforced
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1))
    }

    @ViewBuilder
    private var content: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)   // explicit inner frame before clip
        } else if let localImage = ImageUtils.loadLocalImage(urlString) {
            Image(uiImage: localImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
        } else if let url = URL(string: urlString), !urlString.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                default:
                    placeholder
                }
            }
            .frame(width: size, height: size)       // constrain the AsyncImage container too
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [tint, tint.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(initials)
                .font(.system(size: size * 0.34, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map { String($0) }.joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }

    private var tint: Color {
        let palette: [Color] = [
            Theme.accent,
            Color(red: 0.00, green: 0.48, blue: 1.00),
            Color(red: 0.19, green: 0.69, blue: 0.78),
            Color(red: 1.00, green: 0.58, blue: 0.00),
            Color(red: 0.69, green: 0.32, blue: 0.87)
        ]
        let seed = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[abs(seed) % palette.count]
    }
}
