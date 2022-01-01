//
//  Doors_Widget.swift
//  Doors Widget
//
//  Created by Aryan Vaswani on 12/30/21.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct Doors_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
//            self.view.backgroundColor = UIColor(named: "redBackgroundDoors")
            VStack(spacing: 10) {
                Image("opendoor").resizable().frame(width: 46.0, height: 64.0)
                Text("Nabeel Door").font(Font.headline.weight(.bold))
            }
        }
    }
}

@main
struct Doors_Widget: Widget {
    let kind: String = "Doors_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Doors_WidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))
        }
        .configurationDisplayName("Doors")
        .description("Access doors right from your home screens.")
    }
}

struct Doors_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Doors_WidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
