import SwiftUI
import SwiftData
import CloudKit
import LifeProgressShared

struct ContentView: View {
    @Query(sort: \LifeEvent.eventDate) private var events: [LifeEvent] = []
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
    @State private var selectedTab: Tab = .month
    @State private var selectedBlockDate: Date?
    @State private var showingEventSheet = false
    @State private var livedColor: Color = Color(hex: "26C281")

    enum Tab {
        case week, month, year, settings
    }

    var body: some View {
        let yearsInLife = expectedAge
        let yearsLived = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
        let percentage = Double(yearsLived) / Double(yearsInLife) * 100

        VStack {
            GeometryReader { geometry in
                VStack {
                    ProgressView(value: percentage, total: 100) {
                        HStack {
                            Text("\(yearsLived) years")
                            Spacer()
                            Text(String(format: "%.2f%%", percentage))
                        }
                        .font(.caption)
                    }
                    .accentColor(livedColor)
                    .padding(.horizontal)
                    .opacity(selectedTab == .settings ? 0 : 1)

                    TabView(selection: $selectedTab) {
                        MonthProgressView(width: geometry.size.width, height: geometry.size.height, events: events) { date in
                            selectedBlockDate = date
                            showingEventSheet = true
                        }
                        .tabItem {
                            Label("Month", systemImage: "calendar")
                        }
                        .tag(Tab.month)
                        WeekProgressView(width: geometry.size.width, height: geometry.size.height, events: events) { date in
                            selectedBlockDate = date
                            showingEventSheet = true
                        }
                        .tabItem {
                            Label("Week", systemImage: "calendar")
                        }
                        .tag(Tab.week)
                        YearProgressView(width: geometry.size.width, height: geometry.size.height, events: events) { date in
                            selectedBlockDate = date
                            showingEventSheet = true
                        }
                        .tabItem {
                            Label("Year", systemImage: "calendar")
                        }
                        .tag(Tab.year)
                        SettingsView()
                            .tabItem {
                                Label("Settings", systemImage: "gear")
                            }
                            .tag(Tab.settings)
                    }
                    .padding(selectedTab == .settings ? 0.0 : 16)
                }
            }
        }
        .sheet(isPresented: $showingEventSheet) {
            if let blockDate = selectedBlockDate {
                let blockEndDate = calculateBlockEndDate(from: blockDate)
                let blockEvents = events.filter { $0.eventDate >= blockDate && $0.eventDate < blockEndDate }
                EventListSheet(blockDate: blockDate, events: blockEvents)
            }
        }
        .onAppear {
            if NSUbiquitousKeyValueStore.default.longLong(forKey: "expectedAge") == 0 {
                NSUbiquitousKeyValueStore.default.set(80, forKey: "expectedAge")
            }
            if NSUbiquitousKeyValueStore.default.double(forKey: "birthday") == 0 {
                NSUbiquitousKeyValueStore.default.set(Date(timeIntervalSince1970: 946684800).timeIntervalSince1970, forKey: "birthday")
            }
            NSUbiquitousKeyValueStore.default.synchronize()
            let savedLived = NSUbiquitousKeyValueStore.default.string(forKey: "livedColor") ?? "26C281"
            livedColor = Color(hex: savedLived)
        }
    }

    private func calculateBlockEndDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch selectedTab {
        case .month:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .week:
            return calendar.date(byAdding: .day, value: 7, to: date) ?? date
        case .year:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        case .settings:
            return date
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
