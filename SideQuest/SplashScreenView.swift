import SwiftUI

struct SplashScreenView: View {
    // Logo is immediately visible — only text slides up after appear
    @State private var logoReady = true
    @State private var textVisible = false
    @State private var spinnerVisible = false

    var body: some View {
        ZStack {
            Theme.surface.ignoresSafeArea()

            Circle()
                .fill(Theme.accent.opacity(0.14))
                .frame(width: 360, height: 360)
                .blur(radius: 90)
                .offset(y: -80)
                .ignoresSafeArea()

            Circle()
                .fill(Theme.rose.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: -90, y: 100)
                .ignoresSafeArea()

            Circle()
                .fill(Theme.teal.opacity(0.12))
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
                        // Always visible — no opacity/scale animation on logo

                    VStack(spacing: 8) {
                        Text("SideQuest")
                            .font(.system(size: 34, weight: .bold))
                            .tracking(-0.8)
                            .foregroundStyle(Theme.ink)

                        Text("Swipe on plans, not people")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                    .opacity(textVisible ? 1.0 : 0.0)
                    .offset(y: textVisible ? 0 : 10)
                }

                Spacer()

                ProgressView()
                    .tint(Theme.accent)
                    .scaleEffect(1.1)
                    .opacity(spinnerVisible ? 1.0 : 0.0)
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            // Slight delay so the logo renders first, then text + spinner fade in
            withAnimation(.easeOut(duration: 0.35).delay(0.1)) {
                textVisible = true
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.25)) {
                spinnerVisible = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}

