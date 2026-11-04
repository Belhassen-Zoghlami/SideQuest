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

    func candidates(limit: Int = 40) async throws -> [Student] {
        let snapshot = try await db.collection("users").limit(to: limit).getDocuments()
        return snapshot.documents.compactMap { document in
            guard var student = try? document.data(as: Student.self) else { return nil }
            student.id = document.documentID
            return student
        }
    }

    func likedTargets(by uid: String) async throws -> Set<String> {
        let snapshot = try await db.collection("likes")
            .whereField("actor", isEqualTo: uid)
            .getDocuments()
        return Set(snapshot.documents.compactMap { $0.data()["target"] as? String })
    }

    func saveLike(from me: Student, to target: Student, phone: String) async throws {
        let data: [String: Any] = [
            "actor": me.id,
            "target": target.id,
            "actorPhone": phone,
            "createdAt": Date()
        ]
        try await db.collection("likes").document("\(me.id)_\(target.id)").setData(data)
    }

    func reverseLike(me: Student, target: Student) async throws -> Like? {
        let snapshot = try await db.collection("likes").document("\(target.id)_\(me.id)").getDocument()
        guard snapshot.exists else { return nil }
        return try? snapshot.data(as: Like.self)
    }

    func createMatch(me: Student, target: Student, theirPhone: String, myPhone: String) async throws -> MatchDoc {
        let pair = [me.id, target.id].sorted()
        let matchID = pair.joined(separator: "_")
        let reference = db.collection("matches").document(matchID)

        let existing = try await reference.getDocument()
        if existing.exists, var existingMatch = try? existing.data(as: MatchDoc.self) {
            existingMatch.id = existing.documentID
            return existingMatch
        }

        let shared = Array(Set(me.activities).intersection(Set(target.activities))).sorted()
        let match = MatchDoc(
            id: matchID,
            participants: pair,
            contacts: [me.id: myPhone, target.id: theirPhone],
            names: [me.id: me.displayName, target.id: target.displayName],
            photos: [me.id: me.photoURL, target.id: target.photoURL],
            quests: [me.id: me.quest, target.id: target.quest],
            sharedActivities: shared,
            createdAt: Date()
        )
        try await reference.setData(from: match)
        return match
    }

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

    func uploadAvatar(uid: String, data: Data) async throws -> String {
        let reference = storage.reference().child("avatars/\(uid)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await reference.putDataAsync(data, metadata: metadata)
        return try await reference.downloadURL().absoluteString
    }

    func seedDemoStudents(for me: Student) async throws -> Int {
        var created = 0

        for (index, person) in SeedData.people.enumerated() {
            let uid = "demo_\(String(format: "%02d", index + 1))"
            let userReference = db.collection("users").document(uid)
            let existingUser = try await userReference.getDocument()

            if !existingUser.exists {
                var seeded = person.student
                seeded.id = uid
                seeded.createdAt = Date()
                try await userReference.setData(from: seeded)
                created += 1
            }

            guard index % 2 == 0 else { continue }

            let likeReference = db.collection("likes").document("\(uid)_\(me.id)")
            let existingLike = try await likeReference.getDocument()
            if !existingLike.exists {
                let data: [String: Any] = [
                    "actor": uid,
                    "target": me.id,
                    "actorPhone": person.phone,
                    "createdAt": Date()
                ]
                try await likeReference.setData(data)
            }
        }

        return created
    }
}
