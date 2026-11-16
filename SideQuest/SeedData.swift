import Foundation

struct SeedPerson: Sendable {
    var student: Student
    var phone: String
    var event: EventItem
}

enum SeedData: Sendable {
    static let people: [SeedPerson] = [
        SeedPerson(
            student: Student(
                displayName: "Amina Kessler",
                major: "Computer Science",
                year: "Year 2",
                activities: ["Study", "Coffee", "Hackathon"],
                quest: "Need a study buddy for Data Structures, Tuesdays at 4pm in the library",
                photoURL: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=80"
            ),
            phone: "+1 (555) 010-0101",
            event: EventItem(
                id: "demo_event_01",
                hostId: "demo_01",
                hostName: "Amina Kessler",
                hostPhotoURL: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=80",
                hostContact: "+1 (555) 010-0101",
                hostMajor: "Computer Science",
                hostYear: "Year 2",
                title: "Data Structures Study Jam",
                description: "Reviewing binary trees and graph traversals for next week's midterm. Coffee on me!",
                category: "Study",
                location: "Main Library, 2nd Floor Study Pods",
                eventDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                createdAt: Date(),
                photoURL: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=80"
            )
        ),
        SeedPerson(
            student: Student(
                displayName: "Tomás Ferreira",
                major: "Mechanical Engineering",
                year: "Year 3",
                activities: ["Gym", "Running"],
                quest: "Looking for a gym partner, Tue/Thu mornings before class",
                photoURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&auto=format&fit=crop&q=80"
            ),
            phone: "+1 (555) 010-0102",
            event: EventItem(
                id: "demo_event_02",
                hostId: "demo_02",
                hostName: "Tomás Ferreira",
                hostPhotoURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&auto=format&fit=crop&q=80",
                hostContact: "+1 (555) 010-0102",
                hostMajor: "Mechanical Engineering",
                hostYear: "Year 3",
                title: "Morning Upper Body & Bench Session",
                description: "Looking for a spotter and workout partner. Intermediate lifter, aiming for a quick 1-hour session.",
                category: "Gym",
                location: "Campus Recreation Center (Free Weights)",
                eventDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                createdAt: Date(),
                photoURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&auto=format&fit=crop&q=80"
            )
        ),
        SeedPerson(
            student: Student(
                displayName: "Priya Raman",
                major: "Biomedical Science",
                year: "Masters",
                activities: ["Study", "Language exchange"],
                quest: "Trying to learn Spanish before my exchange semester. Swapping English for Spanish",
                photoURL: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop&q=80"
            ),
            phone: "+1 (555) 010-0103",
            event: EventItem(
                id: "demo_event_03",
                hostId: "demo_03",
                hostName: "Priya Raman",
                hostPhotoURL: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop&q=80",
                hostContact: "+1 (555) 010-0103",
                hostMajor: "Biomedical Science",
                hostYear: "Masters",
                title: "Spanish & English Conversational Exchange",
                description: "Heading to Madrid next semester! Casual chat over tea: 30 minutes in Spanish, 30 minutes in English.",
                category: "Language exchange",
                location: "Student Union Lounge",
                eventDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                createdAt: Date(),
                photoURL: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop&q=80"
            )
        ),
        SeedPerson(
            student: Student(
                displayName: "Noah Whitfield",
                major: "Economics",
                year: "Year 1",
                activities: ["Coffee", "Cowork", "Music"],
                quest: "Anyone want to cowork at the cafe on campus Saturday morning?",
                photoURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&auto=format&fit=crop&q=80"
            ),
            phone: "+1 (555) 010-0104",
            event: EventItem(
                id: "demo_event_04",
                hostId: "demo_04",
                hostName: "Noah Whitfield",
                hostPhotoURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&auto=format&fit=crop&q=80",
                hostContact: "+1 (555) 010-0104",
                hostMajor: "Economics",
                hostYear: "Year 1",
                title: "Saturday Deep Work & Coffee",
                description: "Pomodoro study sprint at the artisan cafe. Focused work blocks with good playlist and coffee breaks.",
                category: "Coffee",
                location: "Brew & Bean Campus Cafe",
                eventDate: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(),
                createdAt: Date(),
                photoURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&auto=format&fit=crop&q=80"
            )
        ),
        SeedPerson(
            student: Student(
                displayName: "Marco Bianchi",
                major: "Computer Science",
                year: "Year 3",
                activities: ["Hackathon", "Gaming", "Coffee"],
                quest: "Building a small app for the campus hackathon, need a designer or a second dev",
                photoURL: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=600&auto=format&fit=crop&q=80"
            ),
            phone: "+1 (555) 010-0106",
            event: EventItem(
                id: "demo_event_05",
                hostId: "demo_05",
                hostName: "Marco Bianchi",
                hostPhotoURL: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=600&auto=format&fit=crop&q=80",
                hostContact: "+1 (555) 010-0106",
                hostMajor: "Computer Science",
                hostYear: "Year 3",
                title: "Campus Hackathon Team Ideation",
                description: "Looking to form a team of 3-4 for this weekend's hackathon! Need someone into SwiftUI, Flutter, or UI Design.",
                category: "Hackathon",
                location: "Innovation Lab (Room 102)",
                eventDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                createdAt: Date(),
                photoURL: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=600&auto=format&fit=crop&q=80"
            )
        ),
        SeedPerson(
            student: Student(
                displayName: "Sofia Lindqvist",
                major: "Psychology",
                year: "Year 2",
                activities: ["Running", "Coffee"],
                quest: "Training for the campus 5k. Looking for a slow-paced running partner",
                photoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&auto=format&fit=crop&q=80"
            ),
            phone: "+1 (555) 010-0107",
            event: EventItem(
                id: "demo_event_06",
                hostId: "demo_06",
                hostName: "Sofia Lindqvist",
                hostPhotoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&auto=format&fit=crop&q=80",
                hostContact: "+1 (555) 010-0107",
                hostMajor: "Psychology",
                hostYear: "Year 2",
                title: "Sunset 5K Campus Loop",
                description: "Easy 6:00 min/km pace around the lake trail. All running levels welcome, smoothie afterwards!",
                category: "Running",
                location: "North Gate Fountain Entrance",
                eventDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                createdAt: Date(),
                photoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&auto=format&fit=crop&q=80"
            )
        ),
        SeedPerson(
            student: Student(
                displayName: "Lucas Almeida",
                major: "Business",
                year: "Year 1",
                activities: ["Cowork", "Gaming", "Coffee"],
                quest: "Smash Bros / Mario Kart tournament in the dorm commons tonight",
                photoURL: "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=600&auto=format&fit=crop&q=80"
            ),
            phone: "+1 (555) 010-0114",
            event: EventItem(
                id: "demo_event_07",
                hostId: "demo_07",
                hostName: "Lucas Almeida",
                hostPhotoURL: "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=600&auto=format&fit=crop&q=80",
                hostContact: "+1 (555) 010-0114",
                hostMajor: "Business",
                hostYear: "Year 1",
                title: "Super Smash Bros & Mario Kart Night",
                description: "Casual gaming tournament on the projector. Bring your Switch controller if you have one! Snacks provided.",
                category: "Gaming",
                location: "Dorm Hall West Commons",
                eventDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                createdAt: Date(),
                photoURL: "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=600&auto=format&fit=crop&q=80"
            )
        )
    ]
}
