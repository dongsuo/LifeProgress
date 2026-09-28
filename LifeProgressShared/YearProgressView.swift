import SwiftUI
import CloudKit

public struct YearProgressView: View {
    let width: CGFloat
    let height: CGFloat
    let events: [LifeEvent]
    let onBlockTap: ((Date) -> Void)?
    let isWidget: Bool
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
    public init(width: CGFloat, height: CGFloat, events: [LifeEvent] = [], onBlockTap: ((Date) -> Void)? = nil, isWidget: Bool = false) {
        self.width = width
        self.height = height
        self.events = events
        self.onBlockTap = onBlockTap
        self.isWidget = isWidget
    }

    public var body: some View {
        let expectedAge = isWidget ? WidgetDataSync.expectedAge : self.expectedAge
        let birthday = isWidget ? WidgetDataSync.birthday : self.birthday
        let livedColor = isWidget ? Color(hex: WidgetDataSync.livedColorHex) : self.livedColor
        let unlivedColor = isWidget ? Color(hex: WidgetDataSync.unlivedColorHex) : self.unlivedColor
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

        Group {
        if isWidget {
            Canvas { context, size in
                let cols = 10
                let rows = (yearsInLife + cols - 1) / cols
                let spacing: CGFloat = 4
                var cell = (size.width - spacing * CGFloat(cols - 1)) / CGFloat(cols)
                let maxCell = (size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows)
                if cell > maxCell { cell = maxCell }
                let gridW = cell * CGFloat(cols) + spacing * CGFloat(cols - 1)
                let gridH = cell * CGFloat(rows) + spacing * CGFloat(rows - 1)
                let originX = (size.width - gridW) / 2
                let originY = (size.height - gridH) / 2
                for index in 0..<yearsInLife {
                    let eventColor = (eventMap[index] ?? []).first.map { Color(hex: $0.colorHex) }
                    let baseLived = eventColor ?? livedColor
                    let baseUnlived = eventColor?.opacity(0.4) ?? unlivedColor
                    let rect = CGRect(x: originX + CGFloat(index % cols) * (cell + spacing), y: originY + CGFloat(index / cols) * (cell + spacing), width: cell, height: cell)
                    let corner = min(4, cell / 4)
                    context.fill(Path(roundedRect: rect, cornerRadius: corner), with: .color(index < yearsLived ? baseLived : baseUnlived))
                    if index == yearsLived {
                        let progressRatio = CGFloat(currentYearProgress) / 365.0
                        let filled = CGRect(x: rect.minX, y: rect.maxY - cell * progressRatio, width: cell, height: cell * progressRatio)
                        context.fill(Path(roundedRect: filled, cornerRadius: corner), with: .color(baseLived))
                    }
                    if eventColor != nil {
                        let dotR = max(1.5, cell / 8)
                        let dot = CGRect(x: rect.midX - dotR, y: rect.maxY - dotR * 2 - 2, width: dotR * 2, height: dotR * 2)
                        context.fill(Path(ellipseIn: dot), with: .color(.white))
                    }
                }
            }
        } else {
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
        }
        }
        .onAppear {
            let defaults = UserDefaults(suiteName: "group.com.v2free.life_progress")
            if defaults?.integer(forKey: "expectedAge") == 0 {
                self.expectedAge = 80
            } else {
                self.expectedAge = Int(defaults?.integer(forKey: "expectedAge") ?? 80) as Int
            }
            if defaults?.double(forKey: "birthday") == 0 {
                self.birthday = Date(timeIntervalSince1970: 946684800)
            } else {
                self.birthday = Date(timeIntervalSince1970: defaults?.double(forKey: "birthday") ?? 946684800)
            }
            self.livedColor = Color(hex: defaults?.string(forKey: "livedColor") ?? "26C281")
            self.unlivedColor = Color(hex: defaults?.string(forKey: "unlivedColor") ?? "E0E0E0")
        }
    }
}

struct YearProgressView_Previews: PreviewProvider {
    static var previews: some View {
        YearProgressView(width: UIScreen.main.bounds.width, height: 0.0)
    }
}
