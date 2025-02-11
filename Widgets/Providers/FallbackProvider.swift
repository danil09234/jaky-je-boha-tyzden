import WidgetKit
import AppCore

struct FallbackProvider: TimelineProvider {
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
        let now = Calendar.current.startOfDay(for: Date())
        var entries: [SimpleEntry] = []

        for dayOffset in 0..<10 {
            if let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: now) {
                let result = FallbackProvider.fetchDisplayState(for: date)
                let entry = SimpleEntry(
                    date: date,
                    displayState: result
                )
                entries.append(entry)
            }
        }

        completion(Timeline(entries: entries, policy: .atEnd))
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
