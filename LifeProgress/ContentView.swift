import SwiftUI
import CloudKit
import LifeProgressShared

struct ContentView: View {

    var body: some View {
        NavigationView {
            TabView {
                WeekProgressView()
                    .tabItem {
                        Label("Week", systemImage: "calendar")
                    }
                MonthProgressView()
                    .tabItem {
                        Label("Month", systemImage: "calendar")
                    }
                YearProgressView()
                    .tabItem {
                        Label("Year", systemImage: "calendar")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .navigationBarTitleDisplayMode(.automatic)
        }
        .onAppear {
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
