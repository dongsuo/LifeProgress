import SwiftUI
import SwiftData
import PhotosUI
import LifeProgressShared

struct LifeEventEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existingEvent: LifeEvent?
    let prefillDate: Date

    @State private var title: String
    @State private var notes: String
    @State private var eventDate: Date
    @State private var color: Color
    @State private var imageData: Data?
    @State private var selectedItem: PhotosPickerItem? = nil

    private let presetColors: [Color] = [
        Color(hex: "26C281"), // emerald
        Color(hex: "3A7BD5"), // ocean blue
        Color(hex: "E55934"), // coral
        Color(hex: "F39C12"), // amber
        Color(hex: "8E44AD"), // violet
        Color(hex: "E84393"), // rose
        Color(hex: "00B894"), // teal
        Color(hex: "6C5CE7"), // indigo
        Color(hex: "FD79A8"), // light pink
        Color(hex: "FDCB6E"), // gold
    ]

    init(existingEvent: LifeEvent? = nil, prefillDate: Date = Date()) {
        self.existingEvent = existingEvent
        self.prefillDate = prefillDate
        if let event = existingEvent {
            _title = State(initialValue: event.title)
            _notes = State(initialValue: event.notes)
            _eventDate = State(initialValue: event.eventDate)
            _color = State(initialValue: Color(hex: event.colorHex))
            _imageData = State(initialValue: event.imageData)
        } else {
            _title = State(initialValue: "")
            _notes = State(initialValue: "")
            _eventDate = State(initialValue: prefillDate)
            _color = State(initialValue: .green)
            _imageData = State(initialValue: nil)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("e.g. College, Graduation, Wedding...", text: $title)
                }

                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $eventDate, displayedComponents: .date)
                }

                Section(header: Text("Color")) {
                    HStack(spacing: 12) {
                        ForEach(presetColors, id: \.self) { preset in
                            Circle()
                                .fill(preset)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    if color.hexString == preset.hexString {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .onTapGesture {
                                    color = preset
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }

                Section(header: Text("Photo")) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                            Text("Add Photo")
                        }
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                #if canImport(UIKit)
                                if let image = UIImage(data: data) {
                                    imageData = image.jpegData(compressionQuality: 0.7)
                                }
                                #endif
                            }
                        }
                    }

                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    self.imageData = nil
                                    selectedItem = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white, .red)
                                        .font(.title2)
                                }
                            }
                    }
                }

                if existingEvent != nil {
                    Section {
                        Button("Delete Event", role: .destructive) {
                            deleteEvent()
                        }
                    }
                }
            }
            .navigationTitle(existingEvent != nil ? "Edit Event" : "New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEvent() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveEvent() {
        if let existingEvent {
            existingEvent.title = title
            existingEvent.notes = notes
            existingEvent.eventDate = eventDate
            existingEvent.colorHex = color.hexString
            existingEvent.imageData = imageData
        } else {
            let newEvent = LifeEvent(title: title,
                                     notes: notes,
                                     eventDate: eventDate,
                                     colorHex: color.hexString,
                                     imageData: imageData)
            modelContext.insert(newEvent)
        }
        try? modelContext.save()
        dismiss()
    }

    private func deleteEvent() {
        if let existingEvent {
            modelContext.delete(existingEvent)
            try? modelContext.save()
        }
        dismiss()
    }
}
