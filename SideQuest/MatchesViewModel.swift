import Foundation
import Observation
import FirebaseFirestore

@MainActor
@Observable
final class MatchesViewModel {
    var matches: [MatchDoc] = []
    var isLoading = true

    private let service = FirebaseService.shared
    private var listener: ListenerRegistration?

    func start(uid: String) {
        guard listener == nil, !uid.isEmpty else { return }

        listener = service.listenMatches(uid: uid) { [weak self] matches in
            guard let self else { return }
            self.matches = matches
            self.isLoading = false
        }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }
}
