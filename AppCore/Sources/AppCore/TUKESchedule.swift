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
        let initialDate = dateYMD(year, month, day)
        let weekday = calendar.component(.weekday, from: initialDate)
        let daysUntilMonday = (2 - weekday + 7) % 7
        return calendar.date(byAdding: .day, value: daysUntilMonday, to: initialDate)!
    }
    
    public static func nextSemesterStart(after date: Date) -> Date {
        let year = calendar.component(.year, from: date)
        return firstMonday(after: year, month: 9, day: 20)
    }
    
    public static func calculateSemesterStart(for referenceDate: Date) throws -> Date {
        let year = calendar.component(.year, from: referenceDate)
        let winterSemesterStart = firstMonday(after: year, month: 9, day: 20)
        let summerSemesterStart = firstMonday(after: year, month: 2, day: 10)

        if let winterBreak = determineWinterBreak(for: referenceDate, year: year) {
            throw winterBreak
        }

        if let examPeriod = determineExamPeriod(for: referenceDate, year: year) {
            throw examPeriod
        }

        if isDateOutOfSemester(referenceDate, year: year) {
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
    
    private static func determineWinterBreak(for date: Date, year: Int) -> SemesterState? {
        if isFirstDayOfYear(date) {
            let examStart = calendar.date(byAdding: .day, value: 1, to: date)!
            return .winterBreakActive(endOfBreak: date, examPeriodStart: examStart)
        }
        
        let winterSemesterStart = firstMonday(after: year, month: 9, day: 20)
        let breakStart = calendar.date(byAdding: .weekOfYear, value: 13, to: winterSemesterStart)!
        let breakEnd = dateYMD(year + 1, 1, 1)
        let examStartAfterBreak = calendar.date(byAdding: .day, value: 1, to: breakEnd)!
        
        if date >= breakStart && date < examStartAfterBreak {
            return .winterBreakActive(endOfBreak: breakEnd, examPeriodStart: examStartAfterBreak)
        }
        return nil
    }
    
    private static func determineExamPeriod(for date: Date, year: Int) -> SemesterState? {
        let examPeriodStart = dateYMD(year, 1, 2)
        let summerSemesterStart = firstMonday(after: year, month: 2, day: 10)
        let examPeriodEnd = calendar.date(byAdding: .day, value: -1, to: summerSemesterStart)!
        
        if date >= examPeriodStart && date <= examPeriodEnd {
            return .examPeriodActive(endOfExams: examPeriodEnd)
        }
        return nil
    }
    
    private static func isFirstDayOfYear(_ date: Date) -> Bool {
        return calendar.component(.day, from: date) == 1 && calendar.component(.month, from: date) == 1
    }
    
    private static func isDateOutOfSemester(_ date: Date, year: Int) -> Bool {
        let juneStart = dateYMD(year, 6, 1)
        let augustEnd = dateYMD(year, 8, 31)
        let septemberStart = dateYMD(year, 9, 1)
        let winterSemesterStart = firstMonday(after: year, month: 9, day: 20)
        let summerSemesterStart = firstMonday(after: year, month: 2, day: 10)
        
        return (date >= juneStart && date <= augustEnd) ||
               (date >= septemberStart && date < winterSemesterStart) ||
               (date < summerSemesterStart)
    }
    
    /// Calculates the current semester week number based on the provided date.
    /// - Parameter date: The reference date.
    /// - Returns: The calculated week number.
    /// - Throws: `SemesterState` if the date is not within a semester.
    public static func calculateWeekNumber(for date: Date) throws -> Int {
        let semesterStart = try calculateSemesterStart(for: date)
        let daysDifference = calendar.dateComponents([.day], from: semesterStart, to: date).day ?? 0
        let weekday = calendar.component(.weekday, from: date)
        let weekOffset = [1, 7].contains(weekday) ? 0 : 1
        return (daysDifference / 7) + weekOffset
    }
}
