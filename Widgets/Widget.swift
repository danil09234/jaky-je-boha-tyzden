import WidgetKit
import SwiftUI
import AppCore
import AppIntents

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
            .description("Displays the current week or special information.")
            .supportedFamilies(families)
        } else {
            return StaticConfiguration(
                kind: kind,
                provider: FallbackProvider()
            ) { entry in
                WeekWidgetEntryView(entry: entry)
            }
            .configurationDisplayName("TUKE Week Widget")
            .description("Displays the current week or special information.")
            .supportedFamilies(families)
        }
    }
}

struct Widget_Previews: PreviewProvider {
    private struct PreviewData {
        let displayName: String
        let timestamp: Double
    }
    
    private static let previewTimelines: [PreviewData] = [
        PreviewData(displayName: "Summer Break", timestamp: 1720569600),
        PreviewData(displayName: "Winter Semester - Week 6", timestamp: 1731196800),
        PreviewData(displayName: "Winter Break", timestamp: 1735325027),
        PreviewData(displayName: "Exam Period", timestamp: 1735689600),
        PreviewData(displayName: "Summer Semester - Week 14", timestamp: 1747267200)
    ]
    
    private static func generateEntry(from timestamp: Double) -> SimpleEntry {
        let date = Date(timeIntervalSince1970: timestamp)
        let displayState: DisplayState
        
        do {
            let week = try TUKESchedule.calculateWeekNumber(for: date)
            displayState = .week(week)
        } catch let state as SemesterState {
            displayState = .specialCase(state)
        } catch {
            displayState = .displayNone
        }
        
        return SimpleEntry(
            date: date,
            displayState: displayState
        )
    }
    
    static var previews: some View {
        Group {
            ForEach(previewTimelines, id: \.displayName) { preview in
                WeekWidgetEntryView(entry: generateEntry(from: preview.timestamp))
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                    .previewDisplayName(preview.displayName)
            }
            
            WeekWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                displayState: .displayNone
            ))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Display None")
        }
    }
}
