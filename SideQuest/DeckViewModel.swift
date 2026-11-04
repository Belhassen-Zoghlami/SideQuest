import Foundation
import Observation

@MainActor
@Observable
final class DeckViewModel {
    var queue: [Student] = []
    var isLoading = true
    var isSwiping = false
    var errorMessage: String?
    var match: MatchDoc?
    var isSeeding = false

    private let service = FirebaseService.shared

    func load(me: Student?) async {
        guard let me else { return }
        isLoading = true
        errorMessage = nil

        do {
            async let allProfiles = service.candidates()
            async let likedIDs = service.likedTargets(by: me.id)
            let (profiles, liked) = try await (allProfiles, likedIDs)

            queue = profiles
                .filter { $0.id != me.id && !liked.contains($0.id) }
                .shuffled()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func swipe(_ student: Student, liked: Bool, me: Student, phone: String) async {
        guard !isSwiping else { return }
        isSwiping = true
        queue.removeAll { $0.id == student.id }

        do {
            try await service.saveLike(from: me, to: student, phone: phone)

            if liked, let reverse = try await service.reverseLike(me: me, target: student) {
                let created = try await service.createMatch(
                    me: me,
                    target: student,
                    theirPhone: reverse.actorPhone,
                    myPhone: phone
                )
                match = created
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isSwiping = false
    }

    func seedDemoData(me: Student) async {
        isSeeding = true
        do {
            _ = try await service.seedDemoStudents(for: me)
            await load(me: me)
        } catch {
            errorMessage = error.localizedDescription
        }
        isSeeding = false
    }
}
