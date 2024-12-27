import WidgetKit
import SwiftUI
import AppCore
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), displayText: "14")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, displayText: fetchWeekNumber())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            configuration: configuration,
            displayText: fetchWeekNumber()
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    @available(iOSApplicationExtension 17.0, *)
    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Current TUKE week indicator")]
    }

    private func fetchWeekNumber() -> String {
        do {
            let week = try TUKESchedule.calculateWeekNumber(for: Date())
            return String(week)
        } catch {
            return ""
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let displayText: String
}

private func heightForFontSize(size: CGFloat) -> CGFloat {
    let font = UIFont.systemFont(ofSize: size)
    return font.capHeight
}

struct WeekWidgetEntryView: View {
    var entry: SimpleEntry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCorner:
            Text(entry.displayText)
                .font(.headline)
                .containerBackground(for: .widget) {}
        case .accessoryCircular:
            Text(entry.displayText)
                .font(.title)
                .containerBackground(for: .widget) {}
        case .accessoryInline:
            Text(entry.displayText)
                .font(.headline)
                .containerBackground(for: .widget) {}
        case .accessoryRectangular:
            Text(entry.displayText)
                .font(.headline)
                .widgetAccentable()
                .containerBackground(for: .widget) {}
#if os(iOS)
        case .systemSmall:
            VStack(spacing: 10) {
                HStack(spacing: 5) {
                    Text("TUKE")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                    Text("Week")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                }
                Text(entry.displayText)
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .frame(height: heightForFontSize(size: 96))
            }
            .containerBackground(for: .widget) {}
#endif
        default:
            Text(entry.displayText)
                .font(.headline)
                .containerBackground(for: .widget) {}
        }
    }
}

@main
struct WeekWidget: Widget {
    let kind: String = "WeekWidget"

    var body: some WidgetConfiguration {
        return AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            WeekWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TUKE Week Widget")
        .description("Displays only a current week.")
#if os(watchOS)
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular,
            .accessoryCorner,
        ])
#else
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular,
            .systemSmall,
        ])
#endif
    }
}

extension ConfigurationAppIntent {
    fileprivate static var sample: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeekWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: .sample, displayText: "14"))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular")
            
            WeekWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: .sample, displayText: "14"))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Rectangular")
            
            WeekWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: .sample, displayText: "Week 14"))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Inline")
#if os(iOS)
            WeekWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: .sample, displayText: "14"))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("System Small")
#endif
        }
    }
}
