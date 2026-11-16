import SwiftUI

struct AuthView: View {
    @State private var vm = AuthViewModel()

    var body: some View {
        @Bindable var vm = vm

        ZStack {
            Theme.surface.ignoresSafeArea()

            Circle()
                .fill(Theme.accent.opacity(0.14))
                .frame(width: 420, height: 420)
                .blur(radius: 90)
                .offset(x: -150, y: -300)
                .ignoresSafeArea()

            Circle()
                .fill(Theme.rose.opacity(0.10))
                .frame(width: 320, height: 320)
                .blur(radius: 85)
                .offset(x: 140, y: -260)
                .ignoresSafeArea()

            Circle()
                .fill(Theme.teal.opacity(0.10))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(x: 80, y: 220)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.top, 56)

                    fieldCard(email: $vm.email, password: $vm.password)
                        .padding(.top, 36)

                    if let error = vm.errorMessage {
                        Label(error, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(Theme.accent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 12)
                    }

                    Button {
                        Task { await vm.submit() }
                    } label: {
                        if vm.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(vm.isSignUp ? "Create account" : "Sign in")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(vm.isLoading)
                    .padding(.top, 20)

                    HStack(spacing: 4) {
                        Text(vm.isSignUp ? "Already have an account?" : "New here?")
                            .foregroundStyle(Theme.muted)
                        Button(vm.isSignUp ? "Sign in" : "Create account") {
                            vm.isSignUp.toggle()
                            vm.errorMessage = nil
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.accent)
                    }
                    .font(.footnote)
                    .padding(.top, 18)

                    Divider()
                        .padding(.vertical, 24)

                    Button("Use demo credentials") {
                        vm.useDemoCredentials()
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.muted)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var header: some View {
        VStack(spacing: 18) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: Theme.accent.opacity(0.35), radius: 18, x: 0, y: 10)

            VStack(spacing: 8) {
                Text("SideQuest")
                    .font(.system(size: 36, weight: .bold))
                    .tracking(-1)
                    .foregroundStyle(Theme.ink)

                Text("Swipe on plans, not people.\nFind someone at your university who is up for the same thing you are.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func fieldCard(email: Binding<String>, password: Binding<String>) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.muted)
                    .frame(width: 20)

                TextField("University email", text: email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .submitLabel(.next)
                    .font(.body)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)

            Divider()
                .padding(.leading, 48)

            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.muted)
                    .frame(width: 20)

                SecureField("Password", text: password)
                    .textContentType(.password)
                    .submitLabel(.go)
                    .font(.body)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
        }
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.control, style: .continuous)
                .stroke(Theme.hairline.opacity(0.4), lineWidth: 0.5)
        )
    }
}

#Preview {
    AuthView()
        .environment(AppState.preview)
}
