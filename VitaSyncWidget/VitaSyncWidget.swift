//
//  VitaSyncWidget.swift
//  VitaSyncWidget
//
//  Created by Manish Jawale on 26/03/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct VitaSyncEntry: TimelineEntry {
    let date: Date
    let data: WidgetHealthData
}

// MARK: - Timeline Provider

struct VitaSyncProvider: TimelineProvider {

    func placeholder(in context: Context) -> VitaSyncEntry {
        VitaSyncEntry(date: Date(), data: .empty)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (VitaSyncEntry) -> Void
    ) {
        let data = WidgetDataStore.shared.load()
        completion(VitaSyncEntry(date: Date(), data: data))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<VitaSyncEntry>) -> Void
    ) {
        let data = WidgetDataStore.shared.load()
        let entry = VitaSyncEntry(date: Date(), data: data)

        // Refresh every hour
        let nextUpdate = Calendar.current.date(
            byAdding: .hour, value: 1, to: Date()
        ) ?? Date()

        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdate)
        )
        completion(timeline)
    }
}

// MARK: - Widget Definition

@main
struct VitaSyncWidgetEntryPoint: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "VitaSyncWidget",
            provider: VitaSyncProvider()
        ) { entry in
            VitaSyncWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("VitaSync")
        .description("Today's health insight and key metrics.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular
        ])
    }
}

// MARK: - Widget View (routes to correct layout by family)

struct VitaSyncWidgetView: View {
    let entry: VitaSyncEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:       SmallWidgetView(entry: entry)
        case .systemMedium:      MediumWidgetView(entry: entry)
        case .accessoryRectangular: LockScreenRectView(entry: entry)
        case .accessoryCircular:    LockScreenCircleView(entry: entry)
        default:                 SmallWidgetView(entry: entry)
        }
    }
}
