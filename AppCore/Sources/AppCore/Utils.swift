import Foundation


public func isoStringToDate(_ isoString: String) -> Date {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate]
    guard let date = formatter.date(from: isoString) else {
        fatalError("Invalid date string: \(isoString)")
    }
    return date
}

public func createDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "sk")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter
}
