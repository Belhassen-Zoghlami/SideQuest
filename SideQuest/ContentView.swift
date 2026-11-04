//
//  ContentView.swift
//  SideQuest
//
//  Created by Tekup-mac-7 on 4/11/2026.
//

import SwiftUI
import FirebaseAuth
struct ContentView: View {
    @Environment(AppState.self) private var appState
    var body: some View {
        Group {
            if appState.authUser == nil {
                AuthView()
            } else if appState.isLoadingProfile {
                ZStack {
                    Theme.surface.ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading your quests…")
                            .font(.footnote)
                            .foregroundStyle(Theme.muted)
                    }
                }
            } else if appState.myProfile == nil {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .task {
            appState.start()
        }
        .animation(.easeInOut(duration: 0.2), value: appState.authUser?.uid)    }
}
struct MainTabView: View {
    @State private var selection: Tab = .deck

    enum Tab: Hashable {
        case deck
        case matches
        case profile
    }

    var body: some View {
        TabView(selection: $selection) {
            DeckView(onSeeMatches: {
                selection = .matches
            })
            .tabItem {
                Label("Discover", systemImage: "square.stack.3d.up.fill")
            }
            .tag(Tab.deck)

            MatchesView()
                .tabItem {
                    Label("Matches", systemImage: "heart.fill")
                }
                .tag(Tab.matches)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(Tab.profile)
        }
        .tint(Theme.accent)
        .toolbarBackground(.regularMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

