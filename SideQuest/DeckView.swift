import SwiftUI

struct DeckView: View {
    @Environment(AppState.self) private var appState
    @State private var vm = DeckViewModel()
    @State private var showCreateEvent = false

    var onSeeMatches: @MainActor @Sendable () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.surface.ignoresSafeArea()

                // Ambient multi-hued light glow
                Circle()
                    .fill(Theme.accent.opacity(0.09))
                    .frame(width: 320, height: 320)
                    .blur(radius: 80)
                    .offset(x: -120, y: -220)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                Circle()
                    .fill(Theme.rose.opacity(0.06))
                    .frame(width: 260, height: 260)
                    .blur(radius: 70)
                    .offset(x: 140, y: -160)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                Circle()
                    .fill(Theme.teal.opacity(0.05))
                    .frame(width: 280, height: 280)
                    .blur(radius: 80)
                    .offset(x: 40, y: 220)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    categoryFilterBar
                        .padding(.top, 4)
                        .padding(.bottom, 8)

                    if vm.isLoading {
                        Spacer()
                        ProgressView("Finding campus events…")
                            .tint(Theme.accent)
                        Spacer()
                    } else if let me = appState.myProfile {
                        if vm.filteredQueue.isEmpty {
                            Spacer()
                            emptyState(me: me)
                            Spacer()
                        } else {
                            deck(me: me)
                        }
                    } else {
                        Spacer()
                        ContentUnavailableView("Profile unavailable", systemImage: "person.crop.circle.badge.exclamationmark")
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1)

                        Text("SideQuest")
                            .font(.system(size: 19, weight: .bold))
                            .tracking(-0.4)
                            .foregroundStyle(Theme.ink)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateEvent = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Post Event")
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.accent, in: Capsule())
                        .foregroundStyle(.white)
                    }
                }
            }
            .task {
                await vm.load(me: appState.myProfile)
            }
            .sheet(isPresented: $showCreateEvent) {
                CreateEventView {
                    Task {
                        await vm.load(me: appState.myProfile)
                    }
                }
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

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryPill(title: "All", isSelected: vm.selectedCategory == nil || vm.selectedCategory == "All") {
                    vm.setCategoryFilter(nil)
                }

                ForEach(ActivityCatalog.all, id: \.self) { category in
                    categoryPill(title: category, isSelected: vm.selectedCategory == category) {
                        vm.setCategoryFilter(category)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func categoryPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        let pillColor = title == "All" ? Theme.accent : Theme.categoryColor(title)

        return Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? pillColor : Theme.fill, in: Capsule())
                .foregroundStyle(isSelected ? Color.white : Theme.ink)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }

    private func deck(me: Student) -> some View {
        let events = Array(vm.filteredQueue.prefix(3))

        return VStack(spacing: 16) {
            ZStack {
                ForEach(Array(events.enumerated()).reversed(), id: \.element.id) { index, event in
                    SwipeCardView(event: event) { liked in
                        Task {
                            await vm.swipe(event, liked: liked, me: me, phone: appState.myPhone)
                        }
                    }
                    .scaleEffect(1 - CGFloat(index) * 0.045)
                    .offset(y: CGFloat(index) * 12)
                    .allowsHitTesting(index == 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 4)

            HStack(spacing: 36) {
                Button {
                    guard let topEvent = vm.filteredQueue.first else { return }
                    Task {
                        await vm.swipe(topEvent, liked: false, me: me, phone: appState.myPhone)
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.red)
                }
                .buttonStyle(CircleIconButtonStyle())
                .accessibilityLabel("Pass")

                Button {
                    guard let topEvent = vm.filteredQueue.first else { return }
                    Task {
                        await vm.swipe(topEvent, liked: true, me: me, phone: appState.myPhone)
                    }
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.green)
                }
                .buttonStyle(CircleIconButtonStyle())
                .accessibilityLabel("Join Event")
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 16)
    }

    private func emptyState(me: Student) -> some View {
        VStack(spacing: 16) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Theme.accent.opacity(0.2), radius: 10, x: 0, y: 4)

            VStack(spacing: 6) {
                Text("No events right now")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.ink)

                Text("You've seen all events in this category. Post your own event or load demo events to test!")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            VStack(spacing: 12) {
                Button {
                    showCreateEvent = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Create an Event")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: 240)

                Button {
                    Task { await vm.seedDemoData(me: me) }
                } label: {
                    if vm.isSeeding {
                        ProgressView().tint(.white)
                    } else {
                        Text("Load demo events")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(maxWidth: 240)
                .disabled(vm.isSeeding)

                Button("Refresh") {
                    Task { await vm.load(me: me) }
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(Theme.muted)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 24)
    }
}

#Preview {
    DeckView(onSeeMatches: {})
        .environment(AppState.preview)
}
