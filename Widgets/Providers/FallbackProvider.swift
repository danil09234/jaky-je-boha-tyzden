import WidgetKit
import AppCore

struct FallbackProvider: TimelineProvider {
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
        let today = FallbackProvider.calendar.startOfDay(for: Date())
        var entries: [SimpleEntry] = []

        for dayOffset in 0..<10 {
            if let entryDate = FallbackProvider.calendar.date(byAdding: .day, value: dayOffset, to: today) {
                let result = FallbackProvider.fetchDisplayState(for: entryDate)
                let entry = SimpleEntry(
                    date: entryDate,
                    displayState: result
                )
                entries.append(entry)
            }
        }
        
        let nextMidnight = FallbackProvider.calendar.date(byAdding: .day, value: 1, to: today)!
        completion(Timeline(entries: entries, policy: .after(nextMidnight)))
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
