import SwiftUI
import CloudKit

public struct MonthProgressView: View {
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
        let monthsInLife = expectedAge * 12
        let monthsLived = Calendar.current.dateComponents([.month], from: birthday, to: Date()).month ?? 0
        let currentMonthProgress = Calendar.current.component(.day, from: Date())
        let blockWidth = (width - 32) / 36
        let blockHeight = blockWidth / 2

        let eventMap: [Int: [LifeEvent]] = {
            var map: [Int: [LifeEvent]] = [:]
            for event in events {
                let m = Calendar.current.dateComponents([.month], from: birthday, to: event.eventDate).month ?? 0
                if m >= 0 && m < monthsInLife {
                    map[m, default: []].append(event)
                }
            }
            return map
        }()

        ScrollView {
            VStack {
                Spacer(minLength: 0)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 20), spacing: 2) {
                ForEach(0..<monthsInLife, id: \.self) { index in
                    let blockEvents = eventMap[index] ?? []
                    let blockStartDate = Calendar.current.date(byAdding: .month, value: index, to: birthday)!
                    let eventColor = blockEvents.first.map { Color(hex: $0.colorHex) }
                    let baseLived = eventColor ?? livedColor
                    let baseUnlived = eventColor?.opacity(0.4) ?? unlivedColor

                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index < monthsLived ? baseLived : baseUnlived)
                            .frame(width: blockWidth, height: blockHeight)

                        if index == monthsLived {
                            let monthLength = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
                            let progressRatio = CGFloat(currentMonthProgress) / CGFloat(monthLength)
                            let filledHeight = blockHeight * progressRatio
                            RoundedRectangle(cornerRadius: 2)
                                .fill(baseLived)
                                .frame(width: blockWidth, height: filledHeight)
                        }

                        if !blockEvents.isEmpty {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 3, height: 3)
                                .overlay {
                                    Circle()
                                        .fill(eventColor ?? livedColor)
                                        .frame(width: 2, height: 2)
                                }
                                .offset(y: -1)
                        }
                    }
                    .shadow(color: index < monthsLived ? (eventColor ?? livedColor).opacity(0.3) : .clear, radius: 1, x: 0, y: 0.5)
                    .onTapGesture {
                        onBlockTap?(blockStartDate)
                    }
                }
            }
            .padding(.horizontal, 16)
                Spacer(minLength: 0)
            }
            .frame(minHeight: height)
        }
        .onAppear {
            let defaults = UserDefaults(suiteName: "group.com.v2free.life_progress")
            if defaults?.integer(forKey: "expectedAge") == 0 {
                expectedAge = 80
            } else {
                expectedAge = Int(defaults?.integer(forKey: "expectedAge") ?? 80)
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
