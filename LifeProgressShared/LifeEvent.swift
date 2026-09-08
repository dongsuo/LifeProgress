œimport Foundation
import SwiftData

@Model
public final class LifeEvent {
    public var id: UUID = UUID()
    public var title: String = ""
    public var notes: String = ""
    public var eventDate: Date = Date()
    public var colorHex: String = "34C759"
    public var imageData: Data? = nil
    public var createdAt: Date = Date()

    public init(title: String = "",
                notes: String = "",
                eventDate: Date = Date(),
                colorHex: String = "34C759",
                imageData: Data? = nil) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.eventDate = eventDate
        self.colorHex = colorHex
        self.imageData = imageData
        self.createdAt = Date()
    }
}

extension LifeEvent: Identifiable {}
