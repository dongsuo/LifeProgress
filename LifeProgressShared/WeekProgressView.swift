import SwiftUI
import CloudKit

public struct WeekProgressView: View {
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
        let weeksPerYear = 52
        let totalWeeks = expectedAge * weeksPerYear
        let daysLived = Calendar.current.dateComponents([.day], from: birthday, to: Date()).day ?? 0
        let weeksLived = daysLived / 7
        let currentWeekProgress = Calendar.current.component(.weekday, from: Date())
        let spacing: CGFloat = 3
        let blockWidth = (width - 32) / CGFloat(weeksPerYear) - spacing
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

        Group {
        if isWidget {
            Canvas { context, size in
                let cols = weeksPerYear
                let rows = expectedAge
                let cellSpacing: CGFloat = 3
                let cellW = (size.width - cellSpacing * CGFloat(cols - 1)) / CGFloat(cols)
                var cellH = cellW
                let maxCellH = (size.height - cellSpacing * CGFloat(rows - 1)) / CGFloat(rows)
                if cellH > maxCellH { cellH = maxCellH }
                let gridW = cellW * CGFloat(cols) + cellSpacing * CGFloat(cols - 1)
                let gridH = cellH * CGFloat(rows) + cellSpacing * CGFloat(rows - 1)
                let originX = (size.width - gridW) / 2
                let originY = (size.height - gridH) / 2
                for index in 0..<totalWeeks {
                    let blockEvents = eventMap[index] ?? []
                    let eventColor = blockEvents.first.map { Color(hex: $0.colorHex) }
                    let baseLived = eventColor ?? livedColor
                    let baseUnlived = eventColor?.opacity(0.4) ?? unlivedColor
                    let rect = CGRect(x: originX + CGFloat(index % cols) * (cellW + cellSpacing), y: originY + CGFloat(index / cols) * (cellH + cellSpacing), width: cellW, height: cellH)
                    let corner = min(2, cellH / 2)
                    context.fill(Path(roundedRect: rect, cornerRadius: corner), with: .color(index < weeksLived ? baseLived : baseUnlived))
                    if index == weeksLived {
                        let progressRatio = CGFloat(currentWeekProgress) / 7.0
                        let filled = CGRect(x: rect.minX, y: rect.maxY - cellH * progressRatio, width: cellW, height: cellH * progressRatio)
                        context.fill(Path(roundedRect: filled, cornerRadius: corner), with: .color(baseLived))
                    }
                    if min(cellW, cellH) >= 5, let theme = blockEvents.lazy.compactMap(\.eventTheme).first {
                        drawThemeSymbol(theme, in: context, at: rect, size: min(cellW, cellH) * 0.8, tint: index < weeksLived ? .white : UIColor(baseLived))
                    }
                }
            }
        } else {
        ScrollView {
            VStack(spacing: 6) {
                ForEach(0..<expectedAge, id: \.self) { yearIndex in
                    HStack(spacing: 4) {
                        HStack(spacing: spacing) {
                            ForEach(0..<weeksPerYear, id: \.self) { weekIndex in
                                let index = yearIndex * weeksPerYear + weekIndex
                                let blockEvents = eventMap[index] ?? []
                                let blockStartDate = Calendar.current.date(byAdding: .day, value: index * 7, to: birthday)!
                                let eventColor = blockEvents.first.map { Color(hex: $0.colorHex) }
                                let baseLived = eventColor ?? livedColor
                                let baseUnlived = eventColor?.opacity(0.4) ?? unlivedColor
                                let fillColor = index < weeksLived ? baseLived : (index == weeksLived ? baseLived.opacity(Double(currentWeekProgress) / 7.0) : baseUnlived)
                                let theme = blockEvents.lazy.compactMap(\.eventTheme).first

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(fillColor)
                                    .frame(width: blockWidth, height: blockHeight)
                                    .overlay {
                                        if let theme {
                                            Image(systemName: theme.resolvedSymbolName)
                                                .font(.system(size: blockHeight * 0.8, weight: .bold))
                                                .foregroundStyle(index < weeksLived ? .white : baseLived)
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
