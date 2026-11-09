import Foundation
import Observation

@MainActor
@Observable
final class DeckViewModel {
    var queue: [EventItem] = []
    var allEvents: [EventItem] = []
    var selectedCategory: String? = nil
    var isLoading = true
    var isSwiping = false
    var errorMessage: String?
    var match: MatchDoc?
    var isSeeding = false

    private let service = FirebaseService.shared

    var filteredQueue: [EventItem] {
        if let selected = selectedCategory, !selected.isEmpty, selected != "All" {
            return queue.filter { $0.category == selected }
        }
        return queue
    }

    func load(me: Student?) async {
        guard let me else { return }
        isLoading = true
        errorMessage = nil

        do {
            async let allFetched = service.fetchEvents(excludingHostUID: me.id)
            async let swipedIDs = service.swipedEventIDs(by: me.id)
            let (events, swiped) = try await (allFetched, swipedIDs)

            let unswiped = events.filter { !swiped.contains($0.id) }

            // Prioritize events that match user's chosen interests
            let myInterests = Set(me.activities)
            let matching = unswiped.filter { myInterests.contains($0.category) }.shuffled()
            let others = unswiped.filter { !myInterests.contains($0.category) }.shuffled()

            allEvents = matching + others
            queue = allEvents
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func setCategoryFilter(_ category: String?) {
        selectedCategory = category
    }

    func swipe(_ event: EventItem, liked: Bool, me: Student, phone: String) async {
        guard !isSwiping else { return }
        isSwiping = true

        queue.removeAll { $0.id == event.id }
        allEvents.removeAll { $0.id == event.id }

        do {
            let resultMatch = try await service.swipeEvent(
                event: event,
                swiper: me,
                swiperPhone: phone,
                liked: liked
            )

            if liked, let resultMatch {
                match = resultMatch
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isSwiping = false
    }

    func seedDemoData(me: Student) async {
        isSeeding = true
        do {
            _ = try await service.seedDemoEvents(for: me)
            await load(me: me)
        } catch {
            errorMessage = error.localizedDescription
        }
        isSeeding = false
    }
}
