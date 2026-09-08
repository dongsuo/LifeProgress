import SwiftUI
import CloudKit

public struct YearProgressView: View {
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
        let yearsInLife = expectedAge
        let yearsLived = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
        let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
        let currentYearProgress = Calendar.current.dateComponents([.day], from: startOfYear, to: Date()).day!
        let blockWidth = (width - 32) / 10

        let eventMap: [Int: [LifeEvent]] = {
            var map: [Int: [LifeEvent]] = [:]
            for event in events {
                let y = Calendar.current.dateComponents([.year], from: birthday, to: event.eventDate).year ?? 0
                if y >= 0 && y < yearsInLife {
                    map[y, default: []].append(event)
                }
            }
            return map
        }()

        ScrollView {
            VStack {
                Spacer(minLength: 0)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: blockWidth))], spacing: 4) {
                ForEach(0..<yearsInLife, id: \.self) { index in
                    let blockEvents = eventMap[index] ?? []
                    let blockStartDate = Calendar.current.date(byAdding: .year, value: index, to: birthday)!
                    let eventColor = blockEvents.first.map { Color(hex: $0.colorHex) }
                    let baseLived = eventColor ?? livedColor
                    let baseUnlived = eventColor?.opacity(0.4) ?? unlivedColor

                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index < yearsLived ? baseLived : baseUnlived)
                            .frame(width: blockWidth, height: blockWidth)

                        if index == yearsLived {
                            let progressRatio = CGFloat(currentYearProgress) / 365.0
                            let filledHeight = blockWidth * progressRatio
                            RoundedRectangle(cornerRadius: 4)
                                .fill(baseLived)
                                .frame(width: blockWidth, height: filledHeight)
                        }

                        if !blockEvents.isEmpty {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 5, height: 5)
                                .overlay {
                                    Circle()
                                        .fill(eventColor ?? livedColor)
                                        .frame(width: 3, height: 3)
                                }
                                .offset(y: -3)
                        }
                    }
                    .shadow(color: index < yearsLived ? baseLived.opacity(0.3) : .clear, radius: 2, x: 0, y: 1)
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

struct YearProgressView_Previews: PreviewProvider {
    static var previews: some View {
        YearProgressView(width: UIScreen.main.bounds.width, height: 0.0)
    }
}
