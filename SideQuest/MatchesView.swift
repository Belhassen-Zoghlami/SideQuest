import SwiftUI

struct MatchesView: View {
    @Environment(AppState.self) private var appState
    @State private var vm = MatchesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading matches…")
                        .tint(Theme.accent)
                } else if vm.matches.isEmpty {
                    emptyState
                } else {
                    List(vm.matches) { match in
                        if let uid = appState.myProfile?.id {
                            NavigationLink {
                                MatchDetailView(match: match)
                            } label: {
                                row(for: match, myUID: uid)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Theme.surface)
                }
            }
            .navigationTitle("Matches")
            .navigationBarTitleDisplayMode(.large)
            .task {
                if let uid = appState.myProfile?.id {
                    vm.start(uid: uid)
                }
            }
        }
    }

    private func row(for match: MatchDoc, myUID: String) -> some View {
        let otherUID = match.otherUID(for: myUID)

        return HStack(spacing: 14) {
            AvatarView(
                name: match.name(for: otherUID),
                urlString: match.photo(for: otherUID),
                size: 52
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(match.name(for: otherUID))
                    .font(.headline)
                    .foregroundStyle(Theme.ink)

                if match.sharedActivities.isEmpty {
                    Text(match.quest(for: otherUID))
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                } else {
                    Text("Both up for \(match.sharedActivities.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundStyle(Theme.accent)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)
        }
        .padding(.vertical, 6)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No matches yet", systemImage: "heart")
        } description: {
            Text("Swipe right on someone whose quest you would join. If they swiped right too, they show up here with their number.")
        }
        .tint(Theme.accent)
    }
}
