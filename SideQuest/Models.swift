import Foundation

struct Student: Identifiable, Codable, Hashable, Sendable {
    var id: String = ""
    var displayName: String = ""
    var major: String = ""
    var year: String = "Year 1"
    var activities: [String] = []
    var quest: String = ""
    var photoURL: String = ""
    var createdAt: Date? = nil
    var lastActive: Date? = nil
}

struct Like: Codable, Hashable, Sendable {
    var actor: String = ""
    var target: String = ""
    var actorPhone: String = ""
    var createdAt: Date? = nil
}

struct MatchDoc: Identifiable, Codable, Hashable, Sendable {
    var id: String = ""
    var participants: [String] = []
    var contacts: [String: String] = [:]
    var names: [String: String] = [:]
    var photos: [String: String] = [:]
    var quests: [String: String] = [:]
    var sharedActivities: [String] = []
    var createdAt: Date? = nil

    func otherUID(for uid: String) -> String {
        participants.first(where: { $0 != uid }) ?? ""
    }

    func name(for uid: String) -> String {
        names[uid] ?? "Student"
    }

    func photo(for uid: String) -> String {
        photos[uid] ?? ""
    }

    func quest(for uid: String) -> String {
        quests[uid] ?? ""
    }

    func phone(for uid: String) -> String {
        contacts[uid] ?? ""
    }
}

enum ActivityCatalog: Sendable {
    static let all = [
        "Study",
        "Cowork",
        "Gym",
        "Coffee",
        "Running",
        "Music",
        "Gaming",
        "Language exchange",
        "Hackathon",
        "Cooking"
    ]

    static let years = [
        "Year 1",
        "Year 2",
        "Year 3",
        "Year 4",
        "Year 5",
        "Masters",
        "PhD"
    ]
}
