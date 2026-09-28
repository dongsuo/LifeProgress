import Foundation
import SwiftData

public enum WidgetDataSync {
    public static let appGroupID = "group.com.v2free.life_progress"
    private static let eventsFileName = "widget_events.json"

    public struct EventSnapshot: Codable {
        public var eventDate: Date
        public var colorHex: String

        public init(eventDate: Date, colorHex: String) {
            self.eventDate = eventDate
            self.colorHex = colorHex
        }
    }

    private static var eventsFileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(eventsFileName)
    }

    public static func saveEvents(_ events: [LifeEvent]) {
        guard let url = eventsFileURL else { return }
        let snapshots = events.map { EventSnapshot(eventDate: $0.eventDate, colorHex: $0.colorHex) }
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
        return snapshots.map { LifeEvent(eventDate: $0.eventDate, colorHex: $0.colorHex) }
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
