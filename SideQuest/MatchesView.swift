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
            .task(id: appState.myProfile?.id) {
                if let uid = appState.myProfile?.id {
                    vm.start(uid: uid)
                }
            }
            .onDisappear {
                vm.stop()
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

            VStack(alignment: .leading, spacing: 4) {
                Text(match.eventTitle.isEmpty ? "Event with \(match.name(for: otherUID))" : match.eventTitle)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if !match.eventCategory.isEmpty {
                        TagChip(title: match.eventCategory)
                    }
                    Text("with \(match.name(for: otherUID))")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)
        }
        .padding(.vertical, 6)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No matches yet", systemImage: "sparkles")
        } description: {
            Text("Swipe right on events you want to join. Matching instantly shares contact details so you can meet up!")
        }
        .tint(Theme.accent)
    }
}
