//
//  SideQuestApp.swift
//  SideQuest
//
//  Created by Tekup-mac-7 on 4/11/2026.
//

import SwiftUI
import FirebaseCore
@main
struct SideQuestApp: App {
    @State private var appState = AppState()
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView().environment(appState)
                .tint(Theme.accent)
        }
    }
}
