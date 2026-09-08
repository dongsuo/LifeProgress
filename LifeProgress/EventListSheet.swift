import SwiftUI
import LifeProgressShared

struct EventListSheet: View {
    let blockDate: Date
    let events: [LifeEvent]
    @Environment(\.dismiss) private var dismiss
    @State private var editingEvent: LifeEvent?
    @State private var showingEditView = false

    var body: some View {
        NavigationStack {
            List {
                if events.isEmpty {
                    Section {
                        Text("No events yet for this period.")
                            .foregroundColor(.secondary)
                    }
                }

                ForEach(events) { event in
                    Button {
                        editingEvent = event
                        showingEditView = true
                    } label: {
                        EventRow(event: event)
                    }
                }

                Section {
                    Button {
                        editingEvent = nil
                        showingEditView = true
                    } label: {
                        Label("Add Event", systemImage: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Life Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingEditView) {
                LifeEventEditView(existingEvent: editingEvent, prefillDate: blockDate)
            }
        }
    }
}

struct EventRow: View {
    let event: LifeEvent

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: event.colorHex))
                .frame(width: 14, height: 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.headline)
                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Text(event.eventDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}
