//
//  AppIntent.swift
//  LifeProgressWidget
//
//  Created by Shaw on 1/3/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Life Progress" }
    static var description: IntentDescription { "Show your life progress" }
    
    func perform() -> some IntentResult {
        // Implement the action to be performed when the intent is triggered
        return .result()
    }
}
