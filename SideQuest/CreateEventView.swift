import SwiftUI

struct CreateEventView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var onCreated: (() -> Void)? = nil

    @State private var title = ""
    @State private var category = "Study"
    @State private var eventDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var location = ""
    @State private var description = ""
    @State private var contactPhone = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private let service = FirebaseService.shared

    var body: some View {
        NavigationStack {
            Form {
                Section("Event Overview") {
                    TextField("e.g. Data Structures Midterm Cram", text: $title)
                        .font(.body)

                    Picker("Category", selection: $category) {
                        ForEach(ActivityCatalog.all, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("When & Where") {
                    DatePicker("Date & Time", selection: $eventDate, in: Date()...)
                        .datePickerStyle(.compact)

                    TextField("e.g. Main Library, 2nd Floor Study Pods", text: $location)
                }

                Section("Details") {
                    TextField("Describe what you're doing, who you're looking for, and what to bring…", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    TextField("Phone number (shared upon match)", text: $contactPhone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                } header: {
                    Text("Host Contact Info")
                } footer: {
                    Text("This phone number is revealed only to students who swipe right to join your event.")
                }

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(Theme.red)
                    }
                }

                Section {
                    Button {
                        Task { await submitEvent() }
                    } label: {
                        if isSubmitting {
                            ProgressView().tint(.white)
                        } else {
                            Text("Post Event")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(enabled: isValid))
                    .disabled(!isValid || isSubmitting)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.surface)
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.muted)
                }
            }
            .onAppear {
                if contactPhone.isEmpty {
                    contactPhone = appState.myPhone
                }
            }
        }
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submitEvent() async {
        guard let me = appState.myProfile else { return }
        isSubmitting = true
        errorMessage = nil

        let phoneToSave = contactPhone.trimmingCharacters(in: .whitespaces).isEmpty
            ? appState.myPhone
            : contactPhone.trimmingCharacters(in: .whitespaces)

        let newEvent = EventItem(
            id: UUID().uuidString,
            hostId: me.id,
            hostName: me.displayName,
            hostPhotoURL: me.photoURL,
            hostContact: phoneToSave,
            hostMajor: me.major,
            hostYear: me.year,
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            category: category,
            location: location.trimmingCharacters(in: .whitespaces),
            eventDate: eventDate,
            createdAt: Date(),
            photoURL: me.photoURL
        )

        do {
            try await service.createEvent(newEvent)
            if !phoneToSave.isEmpty && phoneToSave != appState.myPhone {
                try await service.savePhone(uid: me.id, phone: phoneToSave)
                appState.myPhone = phoneToSave
            }
            onCreated?()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }
}
