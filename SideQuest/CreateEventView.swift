import SwiftUI
import PhotosUI

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

    // Image picker state
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var selectedImage: UIImage? = nil

    private let service = FirebaseService.shared

    var body: some View {
        NavigationStack {
            Form {
                // ── Cover Photo ──────────────────────────────────────
                Section {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Theme.fill)
                                .frame(height: 160)

                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        // Edit badge
                                        HStack(spacing: 4) {
                                            Image(systemName: "pencil")
                                                .font(.caption.weight(.semibold))
                                            Text("Change")
                                                .font(.caption.weight(.semibold))
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(.ultraThinMaterial, in: Capsule())
                                        .padding(10),
                                        alignment: .bottomTrailing
                                    )
                            } else {
                                VStack(spacing: 10) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 32))
                                        .foregroundStyle(Theme.accent)
                                    Text("Add Cover Photo")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Theme.muted)
                                    Text("Optional — makes your event stand out")
                                        .font(.caption)
                                        .foregroundStyle(Theme.muted.opacity(0.7))
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            if let item = newItem,
                               let data = try? await item.loadTransferable(type: Data.self),
                               let compressed = ImageUtils.compress(data, maxDimension: 1200, quality: 0.72),
                               let image = UIImage(data: compressed) {
                                selectedImageData = compressed
                                selectedImage = image
                            }
                        }
                    }
                } header: {
                    Text("Cover Photo")
                }

                // ── Event Overview ───────────────────────────────────
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

                // ── When & Where ─────────────────────────────────────
                Section("When & Where") {
                    DatePicker("Date & Time", selection: $eventDate, in: Date()...)
                        .datePickerStyle(.compact)

                    TextField("e.g. Main Library, 2nd Floor Study Pods", text: $location)
                }

                // ── Details ──────────────────────────────────────────
                Section("Details") {
                    TextField("Describe what you're doing, who you're looking for, and what to bring…", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                // ── Contact ──────────────────────────────────────────
                Section {
                    TextField("Phone number (shared upon match)", text: $contactPhone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                } header: {
                    Text("Host Contact Info")
                } footer: {
                    Text("This phone number is revealed only to students who swipe right to join your event.")
                }

                // ── Error ─────────────────────────────────────────────
                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(Theme.red)
                    }
                }

                // ── Submit ────────────────────────────────────────────
                Section {
                    Button {
                        Task { await submitEvent() }
                    } label: {
                        if isSubmitting {
                            HStack(spacing: 8) {
                                ProgressView().tint(.white)
                                Text(selectedImageData != nil ? "Uploading…" : "Posting…")
                                    .foregroundStyle(.white)
                            }
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

        let eventId = UUID().uuidString

        // Upload event image if one was selected
        var eventPhotoURL = me.photoURL
        if let imageData = selectedImageData {
            do {
                eventPhotoURL = try await service.uploadEventImage(eventId: eventId, data: imageData)
            } catch {
                // Non-fatal: fall back to host photo
                eventPhotoURL = me.photoURL
            }
        }

        let newEvent = EventItem(
            id: eventId,
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
            photoURL: eventPhotoURL
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
