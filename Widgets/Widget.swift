import WidgetKit
import SwiftUI
import AppCore
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            displayText: "14"
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            displayText: fetchWeekNumber()
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            displayText: fetchWeekNumber()
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    @available(iOSApplicationExtension 17.0, *)
    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        [AppIntentRecommendation(
            intent: ConfigurationAppIntent(),
            description: "Current TUKE week indicator"
        )]
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
            containerBackgroundIfAvailable {
                Text(entry.displayText).font(.headline)
            }
        case .accessoryCircular:
            containerBackgroundIfAvailable {
                Text(entry.displayText).font(.title)
            }
        case .accessoryInline:
            containerBackgroundIfAvailable {
                Text(entry.displayText).font(.headline)
            }
        case .accessoryRectangular:
            containerBackgroundIfAvailable {
                Text(entry.displayText).font(.headline).widgetAccentable()
            }
#if os(iOS)
        case .systemSmall:
            containerBackgroundIfAvailable {
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
            }
#endif
        default:
            containerBackgroundIfAvailable {
                Text(entry.displayText).font(.headline)
            }
        }
    }
    
    @ViewBuilder
    private func containerBackgroundIfAvailable<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content()
                .containerBackground(for: .widget) { }
        } else {
            content()
        }
    }
}

@main
struct WeekWidget: Widget {
    let kind: String = "WeekWidget"
    
    var body: some WidgetConfiguration {
#if os(watchOS)
        let families: [WidgetFamily] = [
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular,
            .accessoryCorner
        ]
#else
        let families: [WidgetFamily] = [
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular,
            .systemSmall
        ]
#endif
        
        if #available(iOSApplicationExtension 17.0, *) {
            return AppIntentConfiguration(
                kind: kind,
                intent: ConfigurationAppIntent.self,
                provider: Provider()
            ) { entry in
                WeekWidgetEntryView(entry: entry)
            }
            .configurationDisplayName("TUKE Week Widget")
            .description("Displays only a current week.")
            .supportedFamilies(families)
        } else {
            return StaticConfiguration(
                kind: kind,
                provider: FallbackProvider()
            ) { entry in
                WeekWidgetEntryView(entry: entry)
            }
            .configurationDisplayName("TUKE Week Widget")
            .description("Displays only a current week.")
            .supportedFamilies(families)
        }
    }
}

fileprivate struct FallbackProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            displayText: "14"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(
            SimpleEntry(
                date: Date(),
                displayText: fetchWeekNumber()
            )
        )
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let now = Date()
        let entry = SimpleEntry(
            date: now,
            displayText: fetchWeekNumber()
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
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

extension ConfigurationAppIntent {
    fileprivate static var sample: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeekWidgetEntryView(entry: SimpleEntry(date: Date(), displayText: "14"))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular")
            
            WeekWidgetEntryView(entry: SimpleEntry(date: Date(), displayText: "14"))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Rectangular")
            
            WeekWidgetEntryView(entry: SimpleEntry(date: Date(), displayText: "Week 14"))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Inline")
#if os(iOS)
            WeekWidgetEntryView(entry: SimpleEntry(date: Date(), displayText: "14"))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("System Small")
#endif
        }
    }
}
