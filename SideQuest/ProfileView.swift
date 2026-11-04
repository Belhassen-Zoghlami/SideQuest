import SwiftUI
import PhotosUI
import UIKit
import FirebaseAuth

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    @State private var name = ""
    @State private var major = ""
    @State private var year = "Year 1"
    @State private var selected: Set<String> = []
    @State private var quest = ""
    @State private var phone = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var isSaving = false
    @State private var isSeeding = false
    @State private var message: String?
    @State private var didLoad = false

    private let service = FirebaseService.shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    let hasPhoto = photoItem != nil
                    VStack(spacing: 12) {
                        AvatarView(
                            name: appState.myProfile?.displayName ?? name,
                            urlString: appState.myProfile?.photoURL ?? "",
                            size: 88
                        )
                        .overlay(Circle().stroke(.white, lineWidth: 4))
                        .shadow(color: Theme.cardShadow, radius: 14, x: 0, y: 6)

                        VStack(spacing: 2) {
                            Text(appState.myProfile?.displayName ?? name)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Theme.ink)

                            Text(appState.authUser?.email ?? "")
                                .font(.footnote)
                                .foregroundStyle(Theme.muted)
                        }

                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Text(hasPhoto ? "New photo selected" : "Change photo")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .listRowBackground(Color.clear)

                Section("About you") {
                    TextField("Display name", text: $name)
                        .textContentType(.name)

                    TextField("Major", text: $major)

                    Picker("Year", selection: $year) {
                        ForEach(ActivityCatalog.years, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                        ForEach(ActivityCatalog.all, id: \.self) { activity in
                            Button {
                                toggle(activity)
                            } label: {
                                ActivityChip(title: activity, selected: selected.contains(activity))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("What are you up for?")
                } footer: {
                    Text("Pick up to four.")
                }

                Section("Your side quest") {
                    TextField("Side quest", text: $quest, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    TextField("Phone number", text: $phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                } header: {
                    Text("Contact")
                } footer: {
                    Text("Only shared with people you match with.")
                }

                Section {
                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Save changes")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isSaving)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                }

                if let message {
                    Section {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(Theme.muted)
                    }
                }

                Section {
                    Button {
                        Task { await seed() }
                    } label: {
                        HStack {
                            Text("Load demo students")
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            if isSeeding {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                    }
                    .disabled(isSeeding)

                    Button(role: .destructive) {
                        appState.signOut()
                    } label: {
                        Text("Sign out")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                } header: {
                    Text("Demo tools")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.surface)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .tint(Theme.accent)
            .task { loadIfNeeded() }
        }
    }

    private func loadIfNeeded() {
        guard !didLoad, let me = appState.myProfile else { return }
        name = me.displayName
        major = me.major
        year = me.year
        selected = Set(me.activities)
        quest = me.quest
        phone = appState.myPhone
        didLoad = true
    }

    private func toggle(_ activity: String) {
        if selected.contains(activity) {
            selected.remove(activity)
        } else if selected.count < 4 {
            selected.insert(activity)
        }
    }

    private func save() async {
        guard var student = appState.myProfile else { return }
        isSaving = true
        message = nil

        do {
            student.displayName = name.trimmingCharacters(in: .whitespaces)
            student.major = major.trimmingCharacters(in: .whitespaces)
            student.year = year
            student.activities = selected.sorted()
            student.quest = String(quest.prefix(80))
            student.lastActive = Date()

            if let photoItem,
               let data = try await photoItem.loadTransferable(type: Data.self),
               let compressed = ImageUtils.compress(data) {
                student.photoURL = try await service.uploadAvatar(uid: student.id, data: compressed)
            }

            let trimmedPhone = phone.trimmingCharacters(in: .whitespaces)
            try await service.saveProfile(student)
            try await service.savePhone(uid: student.id, phone: trimmedPhone)

            appState.myProfile = student
            appState.myPhone = trimmedPhone
            photoItem = nil
            message = "Saved."
        } catch {
            message = error.localizedDescription
        }

        isSaving = false
    }

    private func seed() async {
        guard let me = appState.myProfile else { return }
        isSeeding = true
        message = nil

        do {
            let created = try await service.seedDemoStudents(for: me)
            message = created > 0
                ? "Added \(created) demo students. Go to Discover."
                : "Demo students are already loaded."
        } catch {
            message = error.localizedDescription
        }

        isSeeding = false
    }
}
