import SwiftUI
import PhotosUI
import FirebaseAuth

struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    @State private var name = ""
    @State private var major = ""
    @State private var year = "Year 1"
    @State private var selected: Set<String> = []
    @State private var quest = ""
    @State private var phone = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedImageData: Data?
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let service = FirebaseService.shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    let hasPhoto = selectedImage != nil || photoItem != nil
                    HStack(spacing: 16) {
                        AvatarView(name: name, urlString: "", image: selectedImage, size: 68)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(name.isEmpty ? "Your photo" : name)
                                .font(.headline)
                                .lineLimit(1)
                            Text(hasPhoto ? "Photo selected" : "Shown on your card")
                                .font(.footnote)
                                .foregroundStyle(hasPhoto ? Theme.accent : Theme.muted)
                        }

                        Spacer(minLength: 8)

                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Image(systemName: hasPhoto ? "checkmark.circle.fill" : "plus")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.accent)
                                .frame(width: 32, height: 32)
                                .background(Theme.accent.opacity(0.12), in: Circle())
                        }
                    }
                    .padding(.vertical, 4)
                }

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
                    Text("Pick up to four. Matches are ranked by what you share.")
                }

                Section {
                    TextField("e.g. Need a study buddy for Data Structures, Tue 4pm", text: $quest, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("Your side quest (optional)")
                } footer: {
                    Text("\(quest.count)/80")
                        .foregroundStyle(quest.count > 80 ? Theme.accent : Theme.muted)
                        .frame(maxWidth: .infinity, alignment: .trailing)
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

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(Theme.accent)
                    }
                }

                Section {
                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Start swiping")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(enabled: canSave))
                    .disabled(!canSave || isSaving)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.surface)
            .navigationTitle("Create your card")
            .navigationBarTitleDisplayMode(.large)
            .tint(Theme.accent)
            .onChange(of: photoItem) { _, newItem in
                guard let newItem else {
                    selectedImage = nil
                    selectedImageData = nil
                    return
                }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        selectedImageData = data
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !major.trimmingCharacters(in: .whitespaces).isEmpty
            && !phone.trimmingCharacters(in: .whitespaces).isEmpty
            && !selected.isEmpty
    }

    private func toggle(_ activity: String) {
        if selected.contains(activity) {
            selected.remove(activity)
        } else if selected.count < 4 {
            selected.insert(activity)
        }
    }

    private func save() async {
        guard let uid = appState.authUser?.uid else { return }
        errorMessage = nil
        isSaving = true

        do {
            var student = Student()
            student.id = uid
            student.displayName = name.trimmingCharacters(in: .whitespaces)
            student.major = major.trimmingCharacters(in: .whitespaces)
            student.year = year
            student.activities = selected.sorted()
            student.quest = String(quest.prefix(80))
            student.createdAt = Date()
            student.lastActive = Date()

            var dataToUpload = selectedImageData
            if dataToUpload == nil, let photoItem {
                dataToUpload = try? await photoItem.loadTransferable(type: Data.self)
            }
            if let dataToUpload,
               let compressed = ImageUtils.compress(dataToUpload) {
                do {
                    student.photoURL = try await service.uploadAvatar(uid: uid, data: compressed)
                } catch {
                    print("Avatar upload error: \(error)")
                }
            }

            let trimmedPhone = phone.trimmingCharacters(in: .whitespaces)
            try await service.saveProfile(student)
            try await service.savePhone(uid: uid, phone: trimmedPhone)

            appState.myProfile = student
            appState.myPhone = trimmedPhone
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}

#Preview {
    OnboardingView()
        .environment(AppState.preview)
}
