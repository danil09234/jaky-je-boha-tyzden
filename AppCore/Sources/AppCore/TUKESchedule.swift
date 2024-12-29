import Foundation

public class TUKESchedule {
    private static let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }()
    
    public static func dateYMD(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
    
    public static func firstMonday(after year: Int, month: Int, day: Int) -> Date {
        let initial = dateYMD(year, month, day)
        let weekday = calendar.component(.weekday, from: initial)
        let offset = (2 - weekday + 7) % 7
        return calendar.date(byAdding: .day, value: offset, to: initial)!
    }
    
    public static func nextSemesterStart(after date: Date) -> Date {
        let y = calendar.component(.year, from: date)
        return firstMonday(after: y, month: 9, day: 20)
    }
    
    public static func calculateSemesterStart(for referenceDate: Date) throws -> Date {
        let year = calendar.component(.year, from: referenceDate)
        let winterSemesterStart = firstMonday(after: year, month: 9, day: 20)
        let summerSemesterStart = firstMonday(after: year, month: 2, day: 10)

        if let winterBreak = checkWinterBreak(for: referenceDate, year: year) {
            throw winterBreak
        }

        if let examPeriod = checkExamPeriod(for: referenceDate, year: year) {
            throw examPeriod
        }

        if isOutOfSemester(referenceDate, year: year) {
            throw SemesterState.notInSemester(nextSemesterStart: nextSemesterStart(after: referenceDate))
        }

        if referenceDate >= summerSemesterStart && referenceDate < winterSemesterStart {
            return summerSemesterStart
        } else if referenceDate >= winterSemesterStart {
            return winterSemesterStart
        } else {
            return firstMonday(after: year - 1, month: 9, day: 20)
        }
    }
    
    private static func checkWinterBreak(for date: Date, year: Int) -> SemesterState? {
        if calendar.component(.day, from: date) == 1 && calendar.component(.month, from: date) == 1 {
            let examPeriodStart = calendar.date(byAdding: .day, value: 1, to: date)!
            return .winterBreakActive(endOfBreak: date, examPeriodStart: examPeriodStart)
        }
        let winterSemesterStart = firstMonday(after: year, month: 9, day: 20)
        let winterBreakStart = calendar.date(byAdding: .weekOfYear, value: 13, to: winterSemesterStart)!
        let winterBreakEnd = dateYMD(year + 1, 1, 1)
        
        if date >= winterBreakStart && date <= winterBreakEnd {
            let examPeriodStart = calendar.date(byAdding: .day, value: 1, to: winterBreakEnd)!
            return .winterBreakActive(endOfBreak: winterBreakEnd, examPeriodStart: examPeriodStart)
        }
        return nil
    }
    
    private static func checkExamPeriod(for date: Date, year: Int) -> SemesterState? {
        let examPeriodStart = dateYMD(year, 1, 2)
        let summerSemesterStart = firstMonday(after: year, month: 2, day: 10)
        let dayBeforeSummerStart = calendar.date(byAdding: .day, value: -1, to: summerSemesterStart)!
        
        if date >= examPeriodStart && date <= dayBeforeSummerStart {
            return .examPeriodActive(endOfExams: dayBeforeSummerStart)
        }
        return nil
    }
    
    private static func isOutOfSemester(_ date: Date, year: Int) -> Bool {
        let juneStart = dateYMD(year, 6, 1)
        let augEnd = dateYMD(year, 8, 31)
        let septStart = dateYMD(year, 9, 1)
        let winterSemesterStart = firstMonday(after: year, month: 9, day: 20)
        let summerSemesterStart = firstMonday(after: year, month: 2, day: 10)
        
        return (date >= juneStart && date <= augEnd)
            || (date >= septStart && date < winterSemesterStart)
            || (date < summerSemesterStart)
    }
    
    /// Calculates the current semester week number based on the provided date.
    /// - Parameter date: The reference date.
    /// - Returns: The calculated week number.
    /// - Throws: `SemesterState` if the date is not within a semester.
    public static func calculateWeekNumber(for date: Date) throws -> Int {
        let semesterStart = try calculateSemesterStart(for: date)
        let daysDifference = calendar.dateComponents([.day], from: semesterStart, to: date).day ?? 0
        let weekday = calendar.component(.weekday, from: date)
        // Sunday = 1, Saturday = 7 in Calendar
        let weekOffset = [1, 7].contains(weekday) ? 0 : 1
        return (daysDifference / 7) + weekOffset
    }
}
