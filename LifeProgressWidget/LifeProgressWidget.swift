//
//  LifeProgressWidget.swift
//  LifeProgressWidget
//
//  Created by Shaw on 1/3/25.
//

import SwiftUI
import WidgetKit
import LifeProgressShared

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> widgetEntry {
        widgetEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> widgetEntry {
        widgetEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<widgetEntry> {
        var entries: [widgetEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = widgetEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
    
    func getSnapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> widgetEntry {
        let currentDate = Date()
        let entry = widgetEntry(date: currentDate, configuration: configuration)
        
        return entry
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct widgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct YearProgressWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            if size.height > 0 {
                VStack {
                    Text("Yearly Life Progress").font(.caption2).padding(.bottom, -16) // Title with reduced bottom padding
                    YearProgressView(width: size.width, height: size.height)
                        .frame(width: size.width, height: size.height)
                }
            } else {
                Text(entry.date, style: .time)
            }
        }
    }
}

struct MonthProgressWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            if size.height > 0 {
                VStack {
                    Text("Monthly Life Progress").font(.caption2 ).padding(.bottom, -24) // Title extracted from the entry
                MonthProgressView(width: size.width, height: size.height)
                    .frame(width: size.width, height: size.height)
                }
            } else {
                Text(entry.date, style: .time)
            }
        }
    }
}

struct YearProgressWidget: Widget {
    let kind: String = "com.v2free.LifeProgress.YearProgressWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            YearProgressWidgetEntryView(entry: entry)
                .containerBackground(.fill.secondary, for: .widget)
        }.configurationDisplayName("Year Progress")
        .description("Shows the progress of life by year")
        .supportedFamilies([.systemLarge])
    }
}

struct MonthProgressWidget: Widget {
    let kind: String = "com.v2free.LifeProgress.MonthProgressWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            MonthProgressWidgetEntryView(entry: entry)
                .containerBackground(.fill.secondary, for: .widget)
        }.configurationDisplayName("Month Progress")
        .description("Shows the progress of life by month")
        .supportedFamilies([.systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var IntentConfig: ConfigurationAppIntent {
        ConfigurationAppIntent()
    }
}

#Preview(as: .systemLarge) {
    YearProgressWidget()
} timeline: {
    widgetEntry(date: .now, configuration: .IntentConfig)
}

#Preview(as: .systemLarge) {
    MonthProgressWidget()
} timeline: {
    widgetEntry(date: .now, configuration: .IntentConfig)
}
