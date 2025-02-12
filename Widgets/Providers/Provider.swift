import WidgetKit
import SwiftUI
import AppCore
import AppIntents

@available(watchOSApplicationExtension 10.0, *)
@available(iOSApplicationExtension 17.0, *)
struct Provider: AppIntentTimelineProvider {
    private static let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 3600)!
        return cal
    }()
    
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
        var entries: [SimpleEntry] = []
        let today = Provider.calendar.startOfDay(for: Date())
        
        for dayOffset in 0..<10 {
            if let entryDate = Provider.calendar.date(byAdding: .day, value: dayOffset, to: today) {
                let result = fetchDisplayState(for: entryDate)
                let entry = SimpleEntry(
                    date: entryDate,
                    displayState: result
                )
                entries.append(entry)
            }
        }
        
        let nextMidnight = Provider.calendar.date(byAdding: .day, value: 1, to: today)!
        return Timeline(entries: entries, policy: .after(nextMidnight))
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
