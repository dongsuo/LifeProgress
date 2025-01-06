//
//  AppIntent.swift
//  LifeProgressWidget
//
//  Created by Shaw on 1/3/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Life Progress" }
    static var description: IntentDescription { "Show your life progress" }
}
