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
    @State private var selectedImage: UIImage?
    @State private var isUploadingPhoto = false
    @State private var isSaving = false
    @State private var isSeeding = false
    @State private var message: String?
    @State private var myEvents: [EventItem] = []
    @State private var showCreateEvent = false

    private let service = FirebaseService.shared

    var body: some View {
        NavigationStack {
            Form {
                avatarHeader

                aboutSection

                interestsSection

                bioSection

                contactSection

                saveSection

                myEventsSection

                demoAccountSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.surface)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .tint(Theme.accent)
            .task(id: appState.myProfile?.id) {
                loadProfile()
                await loadMyEvents()
            }
            .sheet(isPresented: $showCreateEvent) {
                CreateEventView {
                    Task { await loadMyEvents() }
                }
            }
            .onChange(of: photoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    await handlePhotoSelected(newItem)
                }
            }
        }
    }

    private var avatarHeader: some View {
        Section {
            let hasPhoto = selectedImage != nil || !(appState.myProfile?.photoURL ?? "").isEmpty
            VStack(spacing: 12) {
                ZStack {
                    AvatarView(
                        name: appState.myProfile?.displayName ?? name,
                        urlString: appState.myProfile?.photoURL ?? "",
                        image: selectedImage,
                        size: 88
                    )
                    .overlay(Circle().stroke(.white, lineWidth: 4))
                    .shadow(color: Theme.cardShadow, radius: 14, x: 0, y: 6)

                    if isUploadingPhoto {
                        ProgressView()
                            .tint(.white)
                            .frame(width: 88, height: 88)
                            .background(Color.black.opacity(0.35), in: Circle())
                    }
                }

                VStack(spacing: 2) {
                    Text(appState.myProfile?.displayName ?? name)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Theme.ink)

                    Text(appState.authUser?.email ?? "")
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }

                PhotosPicker(selection: $photoItem, matching: .images) {
                    Text(isUploadingPhoto ? "Uploading photo…" : (hasPhoto ? "Change photo" : "Add photo"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.accent)
                }
                .disabled(isUploadingPhoto)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .listRowBackground(Color.clear)
    }

    private var aboutSection: some View {
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
    }

    private var interestsSection: some View {
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
            Text("Your Interests")
        } footer: {
            Text("Events matching your interests are prioritized in your deck.")
        }
    }

    private var bioSection: some View {
        Section("Bio / Status") {
            TextField("Personal bio", text: $quest, axis: .vertical)
                .lineLimit(2...4)
        }
    }

    private var contactSection: some View {
        Section {
            TextField("Phone number", text: $phone)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
        } header: {
            Text("Contact Phone")
        } footer: {
            Text("Only shared with students who join your events or match with you.")
        }
    }

    private var saveSection: some View {
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

            if let message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            }
        }
    }

    private var myEventsSection: some View {
        Section("My Hosted Events") {
            if myEvents.isEmpty {
                Text("You haven't posted any events yet.")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            } else {
                ForEach(myEvents) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(event.title)
                                .font(.headline)
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            TagChip(title: event.category)
                        }
                        Text(event.location)
                            .font(.caption)
                            .foregroundStyle(Theme.muted)
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) {
                            Task { await deleteMyEvent(event) }
                        }
                    }
                }
            }

            Button {
                showCreateEvent = true
            } label: {
                Label("Post a new event", systemImage: "plus.circle.fill")
                    .foregroundStyle(Theme.accent)
            }
        }
    }

    private var demoAccountSection: some View {
        Section("Demo & Account") {
            Button {
                Task { await seed() }
            } label: {
                HStack {
                    Text("Load demo events & students")
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
        }
    }

    private func loadProfile() {
        guard let me = appState.myProfile else { return }
        name = me.displayName
        major = me.major
        year = me.year
        selected = Set(me.activities)
        quest = me.quest
        phone = appState.myPhone
    }

    private func loadMyEvents() async {
        guard let me = appState.myProfile else { return }
        do {
            myEvents = try await service.myEvents(uid: me.id)
        } catch {
            // Silently handle
        }
    }

    private func deleteMyEvent(_ event: EventItem) async {
        do {
            try await service.deleteEvent(id: event.id)
            myEvents.removeAll { $0.id == event.id }
        } catch {
            message = error.localizedDescription
        }
    }

    private func toggle(_ activity: String) {
        if selected.contains(activity) {
            selected.remove(activity)
        } else if selected.count < 4 {
            selected.insert(activity)
        }
    }

    private func handlePhotoSelected(_ item: PhotosPickerItem) async {
        isUploadingPhoto = true
        message = nil
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                isUploadingPhoto = false
                return
            }
            selectedImage = uiImage

            guard let compressed = ImageUtils.compress(data),
                  var student = appState.myProfile else {
                isUploadingPhoto = false
                return
            }

            let newURL = try await service.uploadAvatar(uid: student.id, data: compressed)
            student.photoURL = newURL
            try await service.saveProfile(student)
            appState.myProfile = student
            message = "Profile photo updated!"
        } catch {
            message = "Failed to update photo: \(error.localizedDescription)"
        }
        isUploadingPhoto = false
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
               let data = try? await photoItem.loadTransferable(type: Data.self),
               let compressed = ImageUtils.compress(data) {
                student.photoURL = try await service.uploadAvatar(uid: student.id, data: compressed)
            }

            let trimmedPhone = phone.trimmingCharacters(in: .whitespaces)
            try await service.saveProfile(student)
            try await service.savePhone(uid: student.id, phone: trimmedPhone)

            appState.myProfile = student
            appState.myPhone = trimmedPhone
            photoItem = nil
            selectedImage = nil
            message = "Profile saved successfully."
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
            let created = try await service.seedDemoEvents(for: me)
            message = created > 0
                ? "Loaded \(created) demo events! Go to Discover to swipe."
                : "Demo events are already loaded."
        } catch {
            message = error.localizedDescription
        }

        isSeeding = false
    }
}
