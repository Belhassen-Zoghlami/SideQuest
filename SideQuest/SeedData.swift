import Foundation

struct SeedPerson: Sendable {
    var student: Student
    var phone: String
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
                photoURL: "https://i.pravatar.cc/600?img=5"
            ),
            phone: "+1 555 0101"
        ),
        SeedPerson(
            student: Student(
                displayName: "Tomás Ferreira",
                major: "Mechanical Engineering",
                year: "Year 3",
                activities: ["Gym", "Running"],
                quest: "Looking for a gym partner, Tue/Thu mornings before class",
                photoURL: "https://i.pravatar.cc/600?img=12"
            ),
            phone: "+1 555 0102"
        ),
        SeedPerson(
            student: Student(
                displayName: "Priya Raman",
                major: "Biomedical Science",
                year: "Masters",
                activities: ["Study", "Language exchange"],
                quest: "Trying to learn Spanish before my exchange semester. Swapping English for Spanish",
                photoURL: "https://i.pravatar.cc/600?img=32"
            ),
            phone: "+1 555 0103"
        ),
        SeedPerson(
            student: Student(
                displayName: "Noah Whitfield",
                major: "Economics",
                year: "Year 1",
                activities: ["Coffee", "Cowork", "Music"],
                quest: "Anyone want to cowork at the cafe on campus Saturday morning?",
                photoURL: "https://i.pravatar.cc/600?img=15"
            ),
            phone: "+1 555 0104"
        ),
        SeedPerson(
            student: Student(
                displayName: "Lena Okonkwo",
                major: "Architecture",
                year: "Year 4",
                activities: ["Study", "Cowork"],
                quest: "All-nighter in the studio this Friday. Someone bring snacks and moral support",
                photoURL: "https://i.pravatar.cc/600?img=45"
            ),
            phone: "+1 555 0105"
        ),
        SeedPerson(
            student: Student(
                displayName: "Marco Bianchi",
                major: "Computer Science",
                year: "Year 3",
                activities: ["Hackathon", "Gaming", "Coffee"],
                quest: "Building a small app for the campus hackathon, need a designer or a second dev",
                photoURL: "https://i.pravatar.cc/600?img=8"
            ),
            phone: "+1 555 0106"
        ),
        SeedPerson(
            student: Student(
                displayName: "Sofia Lindqvist",
                major: "Psychology",
                year: "Year 2",
                activities: ["Running", "Coffee"],
                quest: "Training for the campus 5k. Looking for a slow-paced running partner",
                photoURL: "https://i.pravatar.cc/600?img=20"
            ),
            phone: "+1 555 0107"
        ),
        SeedPerson(
            student: Student(
                displayName: "Daniel Mbeki",
                major: "Mathematics",
                year: "Year 1",
                activities: ["Study", "Gaming"],
                quest: "Struggling with linear algebra. Would trade tutoring for coffee",
                photoURL: "https://i.pravatar.cc/600?img=33"
            ),
            phone: "+1 555 0108"
        ),
        SeedPerson(
            student: Student(
                displayName: "Chloé Martin",
                major: "Graphic Design",
                year: "Year 2",
                activities: ["Coffee", "Cowork", "Music"],
                quest: "Looking for someone to sketch with at the art building, any afternoon",
                photoURL: "https://i.pravatar.cc/600?img=24"
            ),
            phone: "+1 555 0109"
        ),
        SeedPerson(
            student: Student(
                displayName: "Ethan Park",
                major: "Electrical Engineering",
                year: "Year 4",
                activities: ["Study", "Gym", "Hackathon"],
                quest: "Final year project on embedded systems. Would love a second pair of eyes",
                photoURL: "https://i.pravatar.cc/600?img=52"
            ),
            phone: "+1 555 0110"
        ),
        SeedPerson(
            student: Student(
                displayName: "Isabelle Ng",
                major: "International Relations",
                year: "Masters",
                activities: ["Study", "Coffee", "Language exchange"],
                quest: "Writing my thesis and going slightly mad. Accountability buddy needed",
                photoURL: "https://i.pravatar.cc/600?img=26"
            ),
            phone: "+1 555 0111"
        ),
        SeedPerson(
            student: Student(
                displayName: "Youssef Haddad",
                major: "Civil Engineering",
                year: "Year 3",
                activities: ["Gym", "Cooking"],
                quest: "Meal prep Sunday. Looking to split groceries and cook in the shared kitchen",
                photoURL: "https://i.pravatar.cc/600?img=51"
            ),
            phone: "+1 555 0112"
        ),
        SeedPerson(
            student: Student(
                displayName: "Hannah Weiss",
                major: "Chemistry",
                year: "Year 2",
                activities: ["Study", "Running"],
                quest: "Lab report due Friday, need someone to complain with at the library",
                photoURL: "https://i.pravatar.cc/600?img=44"
            ),
            phone: "+1 555 0113"
        ),
        SeedPerson(
            student: Student(
                displayName: "Lucas Almeida",
                major: "Business",
                year: "Year 1",
                activities: ["Cowork", "Gaming", "Coffee"],
                quest: "New on campus and know nobody. Show me where the good coffee is",
                photoURL: "https://i.pravatar.cc/600?img=13"
            ),
            phone: "+1 555 0114"
        ),
        SeedPerson(
            student: Student(
                displayName: "Rania Aziz",
                major: "Physics",
                year: "PhD",
                activities: ["Study", "Music", "Coffee"],
                quest: "Quantum mechanics study group, Thursdays. Tea provided, despair optional",
                photoURL: "https://i.pravatar.cc/600?img=31"
            ),
            phone: "+1 555 0115"
        )
    ]
}
