import Foundation


public func isoStringToDate(_ isoString: String) -> Date {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate]
    formatter.timeZone = TimeZone(secondsFromGMT: 3600)!
    guard let date = formatter.date(from: isoString) else {
        fatalError("Invalid date string: \(isoString)")
    }
    return date
}

public func createDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "sk")
    formatter.timeZone = TimeZone(secondsFromGMT: 3600)!
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter
}


public func fetchDisplayState(for date: Date) -> DisplayState {
    do {
        let week = try TUKESchedule.calculateWeekNumber(for: date)
        return .week(week)
    } catch let state as SemesterState {
        return .specialCase(state)
    } catch {
        return .displayNone
    }
}

