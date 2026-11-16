import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class FirebaseService {
    static let shared = FirebaseService()

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}

    var currentUID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - Profile

    func profile(uid: String) async throws -> Student? {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        guard snapshot.exists else { return nil }
        var student = try snapshot.data(as: Student.self)
        student.id = snapshot.documentID
        return student
    }

    func saveProfile(_ student: Student) async throws {
        try await db.collection("users").document(student.id).setData(from: student)
    }

    func phoneNumber(uid: String) async throws -> String {
        let snapshot = try await db.collection("contacts").document(uid).getDocument()
        guard snapshot.exists else { return "" }
        return snapshot.data()?["phoneNumber"] as? String ?? ""
    }

    func savePhone(uid: String, phone: String) async throws {
        let data: [String: Any] = ["phoneNumber": phone]
        try await db.collection("contacts").document(uid).setData(data)
    }

    // MARK: - Events

    func createEvent(_ event: EventItem) async throws {
        let reference = db.collection("events").document(event.id)
        try reference.setData(from: event)
    }

    func fetchEvents(excludingHostUID: String) async throws -> [EventItem] {
        let snapshot = try await db.collection("events")
            .limit(to: 50)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard var item = try? document.data(as: EventItem.self) else { return nil }
            item.id = document.documentID
            return item
        }
        .filter { $0.hostId != excludingHostUID }
    }

    func myEvents(uid: String) async throws -> [EventItem] {
        let snapshot = try await db.collection("events")
            .whereField("hostId", isEqualTo: uid)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard var item = try? document.data(as: EventItem.self) else { return nil }
            item.id = document.documentID
            return item
        }
        .sorted { $0.eventDate < $1.eventDate }
    }

    func deleteEvent(id: String) async throws {
        try await db.collection("events").document(id).delete()
    }

    // MARK: - Swiping & Matching on Events

    func swipedEventIDs(by uid: String) async throws -> Set<String> {
        let snapshot = try await db.collection("swipes")
            .whereField("actor", isEqualTo: uid)
            .getDocuments()
        return Set(snapshot.documents.compactMap { $0.data()["eventId"] as? String })
    }

    func swipeEvent(event: EventItem, swiper: Student, swiperPhone: String, liked: Bool) async throws -> MatchDoc? {
        let swipeID = "\(swiper.id)_\(event.id)"
        let swipeData: [String: Any] = [
            "actor": swiper.id,
            "eventId": event.id,
            "hostId": event.hostId,
            "action": liked ? "like" : "pass",
            "createdAt": Date()
        ]
        try await db.collection("swipes").document(swipeID).setData(swipeData)

        // Only create a match when swiped right (liked)
        guard liked else { return nil }

        let matchID = "\(event.id)_\(swiper.id)"
        let matchRef = db.collection("matches").document(matchID)
        let existing = try await matchRef.getDocument()
        if existing.exists, var existingMatch = try? existing.data(as: MatchDoc.self) {
            existingMatch.id = existing.documentID
            return existingMatch
        }

        let match = MatchDoc(
            id: matchID,
            eventId: event.id,
            eventTitle: event.title,
            eventCategory: event.category,
            participants: [swiper.id, event.hostId],
            contacts: [
                swiper.id: swiperPhone,
                event.hostId: event.hostContact
            ],
            names: [
                swiper.id: swiper.displayName,
                event.hostId: event.hostName
            ],
            photos: [
                swiper.id: swiper.photoURL,
                event.hostId: event.hostPhotoURL
            ],
            quests: [
                swiper.id: swiper.quest,
                event.hostId: event.description
            ],
            sharedActivities: [event.category],
            createdAt: Date()
        )
        try matchRef.setData(from: match)
        return match
    }

    // MARK: - Matches

    func listenMatches(uid: String, onChange: @escaping ([MatchDoc]) -> Void) -> ListenerRegistration {
        db.collection("matches")
            .whereField("participants", arrayContains: uid)
            .addSnapshotListener { snapshot, _ in
                guard let snapshot else { return }
                let matches = snapshot.documents.compactMap { document -> MatchDoc? in
                    guard var match = try? document.data(as: MatchDoc.self) else { return nil }
                    match.id = document.documentID
                    return match
                }
                .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
                DispatchQueue.main.async {
                    onChange(matches)
                }
            }
    }

    // MARK: - Media & Seed

    func uploadAvatar(uid: String, data: Data) async throws -> String {
        let localIdentifier = ImageUtils.saveLocally(data: data, filename: "avatar_\(uid).jpg")

        do {
            let timestamp = Int(Date().timeIntervalSince1970)
            let reference = storage.reference().child("avatars/\(uid)_\(timestamp).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            _ = try await reference.putDataAsync(data, metadata: metadata)
            return try await reference.downloadURL().absoluteString
        } catch {
            print("Firebase Storage upload error (\(error.localizedDescription)). Using local image persistence.")
            return localIdentifier
        }
    }

    func seedDemoEvents(for me: Student) async throws -> Int {
        var created = 0

        for person in SeedData.people {
            // Seed host user profile if not present
            let userReference = db.collection("users").document(person.student.id.isEmpty ? person.event.hostId : person.student.id)
            let existingUser = try await userReference.getDocument()
            if !existingUser.exists {
                var s = person.student
                s.id = person.event.hostId
                s.createdAt = Date()
                try userReference.setData(from: s)
            }

            // Seed host phone contact
            let contactRef = db.collection("contacts").document(person.event.hostId)
            let existingContact = try await contactRef.getDocument()
            if !existingContact.exists {
                try await contactRef.setData(["phoneNumber": person.phone])
            }

            // Seed event
            let eventRef = db.collection("events").document(person.event.id)
            let existingEvent = try await eventRef.getDocument()
            if !existingEvent.exists {
                var ev = person.event
                ev.createdAt = Date()
                try eventRef.setData(from: ev)
                created += 1
            }
        }

        return created
    }
}
