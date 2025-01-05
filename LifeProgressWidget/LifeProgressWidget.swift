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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
    
    func getSnapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let currentDate = Date()
        let entry: SimpleEntry
        
        if context.isPreview {
            // Use sample data for preview
            entry = SimpleEntry(date: currentDate, configuration: configuration)
        } else {
            // Use actual data if available
            // For now, we'll use the same data as preview
            entry = SimpleEntry(date: currentDate, configuration: configuration)
        }
        
        return entry
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct LifeProgressWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            if size.height > 0 {
                YearProgressView(width: size.width, height: size.height)
                    .frame(width: size.width, height: size.height)
            } else {
                Text(entry.date, style: .time)
            }
        }
    }
}

struct LifeProgressWidget: Widget {
    let kind: String = "com.v2free.LifeProgress.LifeProgressWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            LifeProgressWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }.configurationDisplayName("Life Progress")
        .description("Shows an overview of your life progress")
        .supportedFamilies([.systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
}

#Preview(as: .systemLarge) {
    LifeProgressWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
}
