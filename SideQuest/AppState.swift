import Foundation
import Observation
import FirebaseAuth

@MainActor
@Observable
final class AppState {
    var authUser: User?
    var myProfile: Student?
    var myPhone: String = ""
    var isLoadingProfile = true
    var startupError: String?

    private var authHandle: AuthStateDidChangeListenerHandle?

    func start() {
        guard authHandle == nil else { return }
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                await self?.handleAuthChange(user)
            }
        }
    }

    private func handleAuthChange(_ user: User?) async {
        authUser = user

        guard let user else {
            myProfile = nil
            myPhone = ""
            isLoadingProfile = false
            return
        }

        isLoadingProfile = true
        do {
            let service = FirebaseService.shared
            if var profile = try await service.profile(uid: user.uid) {
                profile.id = user.uid
                myProfile = profile
            } else {
                myProfile = nil
            }
            myPhone = try await service.phoneNumber(uid: user.uid)
        } catch {
            startupError = error.localizedDescription
            myProfile = nil
        }
        isLoadingProfile = false
    }

    func signOut() {
        try? Auth.auth().signOut()
    }
}
