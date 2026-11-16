import Foundation
import Observation
import FirebaseAuth
import FirebaseCore

@MainActor
@Observable
final class AppState {
    var authUser: User?
    var myProfile: Student?
    var myPhone: String = ""
    var isLoadingProfile = true
    var startupError: String?

    private var authHandle: AuthStateDidChangeListenerHandle?

    static func ensureFirebaseConfigured() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    static var preview: AppState {
        ensureFirebaseConfigured()
        let state = AppState()
        state.isLoadingProfile = false
        state.myPhone = "+1 (555) 010-0199"
        state.myProfile = Student(
            id: "preview_user",
            displayName: "Alex Rivera",
            major: "Computer Science",
            year: "Year 3",
            activities: ["Study", "Coffee", "Gaming"],
            quest: "Building iOS apps and finding hackathon teammates!",
            photoURL: ""
        )
        return state
    }

    func start() {
        AppState.ensureFirebaseConfigured()
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
