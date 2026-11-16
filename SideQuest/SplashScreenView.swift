import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Theme.surface.ignoresSafeArea()

            Circle()
                .fill(Theme.accent.opacity(0.14))
                .frame(width: 360, height: 360)
                .blur(radius: 90)
                .offset(y: -50)
                .ignoresSafeArea()

            Circle()
                .fill(Theme.butter.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: 100, y: 120)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 20) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 108, height: 108)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.4), lineWidth: 1.5)
                        )
                        .shadow(color: Theme.accent.opacity(0.35), radius: 24, x: 0, y: 12)
                        .scaleEffect(isAnimating ? 1.0 : 0.82)
                        .opacity(isAnimating ? 1.0 : 0.0)

                    VStack(spacing: 8) {
                        Text("SideQuest")
                            .font(.system(size: 34, weight: .bold))
                            .tracking(-0.8)
                            .foregroundStyle(Theme.ink)

                        Text("Swipe on plans, not people")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 12)
                }

                Spacer()

                ProgressView()
                    .tint(Theme.accent)
                    .scaleEffect(1.1)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.72)) {
                isAnimating = true
            }
        }
    }
}

