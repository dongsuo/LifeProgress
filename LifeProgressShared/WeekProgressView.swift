import SwiftUI
import CloudKit

public struct WeekProgressView: View {
    let width: CGFloat
    let height: CGFloat
    let events: [LifeEvent]
    let onBlockTap: ((Date) -> Void)?
    @State private var expectedAge: Int = {
        let store = NSUbiquitousKeyValueStore.default
        let age = Int(store.longLong(forKey: "expectedAge"))
        return age > 0 ? age : 80
    }()
    @State private var birthday: Date = {
        let store = NSUbiquitousKeyValueStore.default
        let birthdayTimeInterval = store.double(forKey: "birthday")
        return birthdayTimeInterval > 0 ? Date(timeIntervalSince1970: birthdayTimeInterval) : Date(timeIntervalSince1970: 946684800)
    }()
    @State private var livedColor: Color = Color(hex: "26C281")
    @State private var unlivedColor: Color = Color(hex: "E0E0E0")

    public init(width: CGFloat, height: CGFloat, events: [LifeEvent] = [], onBlockTap: ((Date) -> Void)? = nil) {
        self.width = width
        self.height = height
        self.events = events
        self.onBlockTap = onBlockTap
    }

    public var body: some View {
        let weeksPerYear = 52
        let totalWeeks = expectedAge * weeksPerYear
        let daysLived = Calendar.current.dateComponents([.day], from: birthday, to: Date()).day ?? 0
        let weeksLived = daysLived / 7
        let currentWeekProgress = Calendar.current.component(.weekday, from: Date())
        let labelWidth: CGFloat = 28
        let spacing: CGFloat = 3
        let blockWidth = (width - 32 - labelWidth - 8) / CGFloat(weeksPerYear) - spacing
        let blockHeight = max(blockWidth, 5)

        let eventMap: [Int: [LifeEvent]] = {
            var map: [Int: [LifeEvent]] = [:]
            for event in events {
                let d = Calendar.current.dateComponents([.day], from: birthday, to: event.eventDate).day ?? 0
                let w = d / 7
                if w >= 0 && w < totalWeeks {
                    map[w, default: []].append(event)
                }
            }
            return map
        }()

        ScrollView {
            VStack(spacing: 6) {
                ForEach(0..<expectedAge, id: \.self) { yearIndex in
                    HStack(spacing: 4) {
                        Text("\(yearIndex)")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .frame(width: labelWidth, alignment: .trailing)

                        HStack(spacing: spacing) {
                            ForEach(0..<weeksPerYear, id: \.self) { weekIndex in
                                let index = yearIndex * weeksPerYear + weekIndex
                                let blockEvents = eventMap[index] ?? []
                                let blockStartDate = Calendar.current.date(byAdding: .day, value: index * 7, to: birthday)!
                                let eventColor = blockEvents.first.map { Color(hex: $0.colorHex) }
                                let baseLived = eventColor ?? livedColor
                                let baseUnlived = eventColor?.opacity(0.4) ?? unlivedColor
                                let fillColor = index < weeksLived ? baseLived : (index == weeksLived ? baseLived.opacity(Double(currentWeekProgress) / 7.0) : baseUnlived)

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(fillColor)
                                    .frame(width: blockWidth, height: blockHeight)
                                    .overlay {
                                        if !blockEvents.isEmpty {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 3, height: 3)
                                                .overlay {
                                                    Circle()
                                                        .fill(eventColor ?? livedColor)
                                                        .frame(width: 2, height: 2)
                                                }
                                        }
                                    }
                                    .shadow(color: index < weeksLived ? baseLived.opacity(0.2) : .clear, radius: 0.8, x: 0, y: 0.5)
                                    .onTapGesture {
                                        onBlockTap?(blockStartDate)
                                    }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .onAppear {
            let defaults = UserDefaults(suiteName: "group.com.v2free.life_progress")
            if defaults?.integer(forKey: "expectedAge") == 0 {
                expectedAge = 80
            } else {
                expectedAge = Int(defaults?.integer(forKey: "expectedAge") ?? 80) as Int
            }
            if defaults?.double(forKey: "birthday") == 0 {
                birthday = Date(timeIntervalSince1970: 946684800)
            } else {
                birthday = Date(timeIntervalSince1970: defaults?.double(forKey: "birthday") ?? 946684800)
            }
            livedColor = Color(hex: defaults?.string(forKey: "livedColor") ?? "26C281")
            unlivedColor = Color(hex: defaults?.string(forKey: "unlivedColor") ?? "E0E0E0")
        }
    }
}
