import Foundation
import SwiftData

public enum WidgetDataSync {
    public static let appGroupID = "group.com.v2free.life_progress"
    private static let eventsFileName = "widget_events.json"

    public struct EventSnapshot: Codable {
        public var eventDate: Date
        public var colorHex: String
        public var title: String?

        public init(eventDate: Date, colorHex: String, title: String? = nil) {
            self.eventDate = eventDate
            self.colorHex = colorHex
            self.title = title
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            eventDate = try container.decode(Date.self, forKey: .eventDate)
            colorHex = try container.decode(String.self, forKey: .colorHex)
            title = try container.decodeIfPresent(String.self, forKey: .title)
        }
    }

    private static var eventsFileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(eventsFileName)
    }

    public static func saveEvents(_ events: [LifeEvent]) {
        guard let url = eventsFileURL else { return }
        let snapshots = events.map { EventSnapshot(eventDate: $0.eventDate, colorHex: $0.colorHex, title: $0.title) }
        if let data = try? JSONEncoder().encode(snapshots) {
            try? data.write(to: url, options: .atomic)
        }
    }

    public static func loadEvents() -> [LifeEvent] {
        guard let url = eventsFileURL,
              let data = try? Data(contentsOf: url),
              let snapshots = try? JSONDecoder().decode([EventSnapshot].self, from: data) else {
            return []
        }
        return snapshots.map { LifeEvent(title: $0.title ?? "", eventDate: $0.eventDate, colorHex: $0.colorHex) }
    }

    public static var expectedAge: Int {
        let defaults = UserDefaults(suiteName: appGroupID)
        let age = defaults?.integer(forKey: "expectedAge") ?? 0
        return age > 0 ? age : 80
    }

    public static var birthday: Date {
        let defaults = UserDefaults(suiteName: appGroupID)
        let t = defaults?.double(forKey: "birthday") ?? 0
        return t > 0 ? Date(timeIntervalSince1970: t) : Date(timeIntervalSince1970: 946684800)
    }

    public static var livedColorHex: String {
        UserDefaults(suiteName: appGroupID)?.string(forKey: "livedColor") ?? "26C281"
    }

    public static var unlivedColorHex: String {
        UserDefaults(suiteName: appGroupID)?.string(forKey: "unlivedColor") ?? "E0E0E0"
    }
}
