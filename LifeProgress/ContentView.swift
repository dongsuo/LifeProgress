import SwiftUI
import CloudKit
import LifeProgressShared

struct ContentView: View {
    @State private var expectedAge: Int = {
        let store = NSUbiquitousKeyValueStore.default
        let age = Int(store.longLong(forKey: "expectedAge"))
        return age > 0 ? age : 80 // Fallback to 80 if not set
    }()
    @State private var birthday: Date = {
        let store = NSUbiquitousKeyValueStore.default
        let birthdayTimeInterval = store.double(forKey: "birthday")
        return birthdayTimeInterval > 0 ? Date(timeIntervalSince1970: birthdayTimeInterval) : Date() // Fallback to current date if not set
    }()
    @State private var selectedTab: Tab = .month
    
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
                    .accentColor(.green)
                    .padding(.horizontal)
                    .opacity(selectedTab == .settings ? 0 : 1)

                    TabView(selection: $selectedTab) {
                        MonthProgressView(width: geometry.size.width, height: geometry.size.height)
                            .tabItem {
                                Label("Month", systemImage: "calendar")
                            }
                            .tag(Tab.month)
                        WeekProgressView(width: geometry.size.width, height: geometry.size.height)
                            .tabItem {
                                Label("Week", systemImage: "calendar")
                            }
                            .tag(Tab.week)
                        YearProgressView(width: geometry.size.width, height: geometry.size.height)
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
        .onAppear {
            if NSUbiquitousKeyValueStore.default.longLong(forKey: "expectedAge") == 0 {
                NSUbiquitousKeyValueStore.default.set(80, forKey: "expectedAge")
            }
            if NSUbiquitousKeyValueStore.default.double(forKey: "birthday") == 0 {
                NSUbiquitousKeyValueStore.default.set(Date(timeIntervalSince1970: 946684800).timeIntervalSince1970, forKey: "birthday")
            }
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
