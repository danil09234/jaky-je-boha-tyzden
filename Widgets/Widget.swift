import WidgetKit
import SwiftUI
import AppCore
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            displayState: .week(14)
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let result = fetchDisplayState(for: Date())
        return SimpleEntry(
            date: Date(),
            displayState: result
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let result = fetchDisplayState(for: currentDate)
        let entry = SimpleEntry(
            date: currentDate,
            displayState: result
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

    private func fetchDisplayState(for date: Date) -> DisplayState {
        do {
            let week = try TUKESchedule.calculateWeekNumber(for: date)
            return .week(week)
        } catch let state as SemesterState {
            return .specialCase(state)
        } catch {
            return .displayNone
        }
    }
}

enum DisplayState {
    case week(Int)
    case specialCase(SemesterState)
    case displayNone
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let displayState: DisplayState
}

private func heightForFontSize(size: CGFloat) -> CGFloat {
    let font = UIFont.systemFont(ofSize: size)
    return font.capHeight
}

extension SemesterState {
    var iconName: String {
        switch self {
        case .winterBreakActive:
            return "snowflake"
        case .examPeriodActive:
            return "book.closed"
        case .notInSemester:
            return "sun.max"
        }
    }
    
    var color: Color {
        switch self {
        case .winterBreakActive:
            return .blue
        case .examPeriodActive:
            return .green
        case .notInSemester:
            return .orange
        }
    }
    
    var shortDescription: String {
        switch self {
        case .winterBreakActive:
            return "Prestávka"
        case .examPeriodActive:
            return "Skúšky"
        case .notInSemester:
            return "Prestávka"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .winterBreakActive(_, let examPeriodStart):
            return "Skúškové začína\n\(SemesterViewModelBase.formatter.string(from: examPeriodStart))"
        case .examPeriodActive(let endOfExams):
            return "Skúškové končí\n\(SemesterViewModelBase.formatter.string(from: endOfExams))"
        case .notInSemester(let nextSemesterStart):
            return "Vidíme sa\n\(SemesterViewModelBase.formatter.string(from: nextSemesterStart))!"
        }
    }
}


struct WeekWidgetEntryView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCorner:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    HStack(alignment: .center) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("\(week)")
                            .font(.title)
                            .widgetAccentable()
                            .bold()
                    }
                case .specialCase(let state):
                    Image(systemName: state.iconName)
                        .widgetAccentable()
                        .bold()
                        .font(.largeTitle)
                case .displayNone:
                    Text("-")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
        
        case .accessoryCircular:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    VStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("\(week)")
                            .font(.largeTitle)
                            .widgetAccentable()
                            .bold()
                    }
                case .specialCase(let state):
                    VStack {
#if os(watchOS)
                        Image(systemName: state.iconName)
                            .font(.largeTitle)
                            .foregroundColor(state.color)
#else
                        Image(systemName: state.iconName)
                            .font(.title2)
                            .foregroundColor(state.color)
                        Text(state.shortDescription)
                            .font(.caption)
                            .foregroundColor(state.color)
#endif
                    }
                case .displayNone:
                    Text("-")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
        case .accessoryInline:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    HStack {
                        Image(systemName: "calendar")
                        Text("Week \(week)")
                            .font(.headline)
                            .widgetAccentable()
                    }
                case .specialCase(let state):
                    HStack {
                        Image(systemName: state.iconName)
                        Text(state.shortDescription)
                            .font(.headline)
                            .widgetAccentable()
                    }
                case .displayNone:
                    Text("-")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
        case .accessoryRectangular:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    HStack {
                        Image(systemName: "calendar")
                            .font(.largeTitle)
                        VStack {
                            Text("TUKE")
                                .foregroundColor(.red)
                                .bold()
                            Text("Week")
                                .foregroundColor(.gray)
                        }
                        Text("\(week)")
                            .font(.title)
                            .bold()
                    }
                case .specialCase(let state):
                    HStack(spacing: 10) {
                        Image(systemName: state.iconName)
                            .font(.title)
                            .foregroundColor(state.color)
                        Text(state.shortDescription)
                            .font(.headline)
                    }
                case .displayNone:
                    Text("-")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
        case .systemSmall:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    VStack(spacing: 10) {
                        HStack(spacing: 5) {
                            Text("TUKE")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                            Text("Week")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        Text("\(week)")
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .frame(height: heightForFontSize(size: 96))
                    }
                case .specialCase(let state):
                    VStack(spacing: 10) {
                        Image(systemName: state.iconName)
                            .font(.largeTitle)
                            .foregroundColor(state.color)
                        Text(state.detailedDescription)
                            .font(.body)
                            .multilineTextAlignment(.center)
                    }
                case .displayNone:
                    VStack {
                        Text("-")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
        
        default:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    Text("\(week)")
                        .font(.headline)
                        .foregroundColor(.white)
                case .specialCase(let state):
                    Image(systemName: state.iconName)
                        .foregroundColor(state.color)
                        .font(.headline)
                case .displayNone:
                    Text("-")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func shortErrorMessage(for state: SemesterState) -> String {
        return state.shortDescription
    }
    
    private func detailedErrorMessage(for state: SemesterState) -> String {
        return state.detailedDescription
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

fileprivate struct FallbackProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            displayState: .week(14)
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let result = FallbackProvider.fetchDisplayState(for: Date())
        completion(
            SimpleEntry(
                date: Date(),
                displayState: result
            )
        )
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let now = Date()
        let result = FallbackProvider.fetchDisplayState(for: now)
        let entry = SimpleEntry(
            date: now,
            displayState: result
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
    
    private static func fetchDisplayState(for date: Date) -> DisplayState {
        do {
            let week = try TUKESchedule.calculateWeekNumber(for: date)
            return .week(week)
        } catch let state as SemesterState {
            return .specialCase(state)
        } catch {
            return .displayNone
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
