//
//  LifeProgressApp.swift
//  LifeProgress
//
//  Created by Shaw on 1/3/25.
//

import SwiftUI
import SwiftData
import LifeProgressShared

@main
struct LifeProgressApp: App {
    var sharedModelContainer: ModelContainer = {
        UserDefaults.standard.set(true, forKey: "com.apple.SwiftData.Logging")
        let schema = Schema([
            LifeEvent.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: Unknown error - \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
