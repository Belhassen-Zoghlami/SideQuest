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
    @State private var isSplashActive = true

    var body: some View {
        ZStack {
            Group {
                if appState.authUser == nil {
                    AuthView()
                } else if appState.isLoadingProfile {
                    SplashScreenView()
                } else if appState.myProfile == nil {
                    OnboardingView()
                } else {
                    MainTabView()
                }
            }

            if isSplashActive {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            appState.start()
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            withAnimation(.easeInOut(duration: 0.45)) {
                isSplashActive = false
            }
        }
        .animation(.easeInOut(duration: 0.25), value: appState.authUser?.uid)
    }
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

#Preview {
    ContentView()
        .environment(AppState.preview)
}

