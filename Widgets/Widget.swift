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
        let result = fetchDisplayState()
        return SimpleEntry(
            date: Date(),
            displayState: result
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let result = fetchDisplayState()
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

    private func fetchDisplayState() -> DisplayState {
        do {
            let week = try TUKESchedule.calculateWeekNumber(for: Date())
            return .week(week)
        } catch let error as SemesterError {
            return .error(error)
        } catch {
            return .displayNone
        }
    }
}

enum DisplayState {
    case week(Int)
    case error(SemesterError)
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

struct WeekWidgetEntryView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCorner:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    Text("\(week)").font(.headline)
                case .error(let error):
                    Text(errorMessage(for: error)).font(.headline)
                case .displayNone:
                    Text("-").font(.headline)
                }
            }
        case .accessoryCircular:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    Text("\(week)").font(.title)
                case .error(_):
                    Text("Error").font(.title)
                case .displayNone:
                    Text("-").font(.title)
                }
            }
        case .accessoryInline:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    Text("Week \(week)").font(.headline)
                case .error:
                    Text("Error fetching week").font(.headline)
                case .displayNone:
                    Text("-").font(.headline)
                }
            }
        case .accessoryRectangular:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    Text("Week \(week)").font(.headline).widgetAccentable()
                case .error:
                    Text("Error").font(.headline).widgetAccentable()
                case .displayNone:
                    Text("-").font(.headline).widgetAccentable()
                }
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
                    switch entry.displayState {
                    case .week(let week):
                        Text("\(week)")
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .frame(height: heightForFontSize(size: 96))
                    case .error:
                        Text("Error")
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .frame(height: heightForFontSize(size: 96))
                    case .displayNone:
                        Text("-")
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .frame(height: heightForFontSize(size: 96))
                    }
                }
            }
#endif
        default:
            containerBackgroundIfAvailable {
                switch entry.displayState {
                case .week(let week):
                    Text("\(week)").font(.headline)
                case .error:
                    Text("N/A").font(.headline)
                case .displayNone:
                    Text("-").font(.headline)
                }
            }
        }
    }
    
    private func errorMessage(for error: SemesterError) -> String {
        switch error {
        case .winterBreakActive:
            return "Winter Break"
        case .examPeriodActive:
            return "Exam Period"
        case .notInSemester:
            return "Not in Semester"
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
            .description("Displays the current week or error information.")
            .supportedFamilies(families)
        } else {
            return StaticConfiguration(
                kind: kind,
                provider: FallbackProvider()
            ) { entry in
                WeekWidgetEntryView(entry: entry)
            }
            .configurationDisplayName("TUKE Week Widget")
            .description("Displays the current week or error information.")
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
        let result = FallbackProvider.fetchDisplayState()
        completion(
            SimpleEntry(
                date: Date(),
                displayState: result
            )
        )
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let now = Date()
        let result = FallbackProvider.fetchDisplayState()
        let entry = SimpleEntry(
            date: now,
            displayState: result
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
    
    private static func fetchDisplayState() -> DisplayState {
        do {
            let week = try TUKESchedule.calculateWeekNumber(for: Date())
            return .week(week)
        } catch let error as SemesterError {
            return .error(error)
        } catch {
            return .error(.notInSemester(nextSemesterStart: Date()))
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
        PreviewData(displayName: "Summer break", timestamp: 1720569600),
        PreviewData(displayName: "Winter semester - Week 6", timestamp: 1731196800),
        PreviewData(displayName: "Winter break", timestamp: 1735325027),
        PreviewData(displayName: "Winter exams", timestamp: 1735689600),
        PreviewData(displayName: "Summer semester - Week 2", timestamp: 1740787200)
    ]
    
    private static func generateEntry(from timestamp: Double) -> SimpleEntry {
        let date = Date(timeIntervalSince1970: timestamp)
        let displayState: DisplayState
        
        do {
            let week = try TUKESchedule.calculateWeekNumber(for: date)
            displayState = .week(week)
        } catch let error as SemesterError {
            displayState = .error(error)
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
    
    private static func heightForFontSize(size: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: size)
        return font.capHeight
    }
}
