import SwiftUI

struct DeckView: View {
    @Environment(AppState.self) private var appState
    @State private var vm = DeckViewModel()

    var onSeeMatches: @MainActor @Sendable () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.surface.ignoresSafeArea()

                RadialGradient(
                    colors: [Theme.accent.opacity(0.10), .clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 420
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                if vm.isLoading {
                    ProgressView("Finding quests…")
                        .tint(Theme.accent)
                } else if let me = appState.myProfile {
                    if vm.queue.isEmpty {
                        emptyState(me: me)
                    } else {
                        deck(me: me)
                    }
                } else {
                    ContentUnavailableView("Profile unavailable", systemImage: "person.crop.circle.badge.exclamationmark")
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await vm.load(me: appState.myProfile)
            }
            .overlay {
                if let match = vm.match, let uid = appState.myProfile?.id {
                    MatchOverlay(
                        match: match,
                        myUID: uid,
                        onSeeMatches: {
                            vm.match = nil
                            onSeeMatches()
                        },
                        onDismiss: {
                            vm.match = nil
                        }
                    )
                }
            }
            .alert("Something went wrong", isPresented: errorBinding) {
                Button("OK", role: .cancel) {
                    vm.errorMessage = nil
                }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )
    }

    private func deck(me: Student) -> some View {
        VStack(spacing: 16) {
            ZStack {
                ForEach(Array(vm.queue.prefix(3).indices).reversed(), id: \.self) { index in
                    let student = vm.queue[index]
                    SwipeCardView(student: student) { liked in
                        Task {
                            await vm.swipe(student, liked: liked, me: me, phone: appState.myPhone)
                        }
                    }
                    .id(student.id)
                    .scaleEffect(1 - CGFloat(index) * 0.045)
                    .offset(y: CGFloat(index) * 12)
                    .allowsHitTesting(index == 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 6)

            HStack(spacing: 28) {
                Button {
                    guard let student = vm.queue.first else { return }
                    Task {
                        await vm.swipe(student, liked: false, me: me, phone: appState.myPhone)
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(Theme.red)
                }
                .buttonStyle(CircleIconButtonStyle())
                .accessibilityLabel("Pass")

                Button {
                    guard let student = vm.queue.first else { return }
                    Task {
                        await vm.swipe(student, liked: true, me: me, phone: appState.myPhone)
                    }
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Theme.green)
                }
                .buttonStyle(CircleIconButtonStyle())
                .accessibilityLabel("Interested")
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 16)
    }

    private func emptyState(me: Student) -> some View {
        ContentUnavailableView {
            Label("No more quests", systemImage: "sparkles")
        } description: {
            Text("You have seen every student in the deck. Load demo students to keep testing.")
        } actions: {
            Button {
                Task { await vm.seedDemoData(me: me) }
            } label: {
                if vm.isSeeding {
                    ProgressView().tint(.white)
                } else {
                    Text("Load demo students")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 260)
            .disabled(vm.isSeeding)

            Button("Refresh deck") {
                Task { await vm.load(me: me) }
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(Theme.muted)
        }
        .tint(Theme.accent)
    }
}
