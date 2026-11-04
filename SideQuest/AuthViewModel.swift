import Foundation
import Observation
import FirebaseAuth

@MainActor
@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var isSignUp = false
    var isLoading = false
    var errorMessage: String?

    func submit() async {
        errorMessage = nil
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard cleanEmail.contains("@"), cleanEmail.contains(".") else {
            errorMessage = "Enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        isLoading = true
        do {
            if isSignUp {
                _ = try await Auth.auth().createUser(withEmail: cleanEmail, password: password)
            } else {
                _ = try await Auth.auth().signIn(withEmail: cleanEmail, password: password)
            }
        } catch {
            errorMessage = message(for: error)
        }
        isLoading = false
    }

    func useDemoCredentials() {
        email = "demo@sidequest.app"
        password = "sidequest123"
        isSignUp = true
    }

    private func message(for error: Error) -> String {
        let nsError = error as NSError
        switch AuthErrorCode(rawValue: nsError.code) {
        case .emailAlreadyInUse?:
            return "That email already has an account. Switch to Sign In."
        case .invalidEmail?:
            return "That email address doesn't look right."
        case .weakPassword?:
            return "Choose a password with at least 6 characters."
        case .wrongPassword?, .invalidCredential?:
            return "Email or password is incorrect."
        case .userNotFound?:
            return "No account for that email yet. Switch to Create Account."
        case .networkError?:
            return "Network problem. Check the lab Wi-Fi and try again."
        case .tooManyRequests?:
            return "Too many attempts. Wait a minute and try again."
        default:
            return nsError.localizedDescription
        }
    }
}
