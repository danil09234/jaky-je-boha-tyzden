import Foundation

public class TUKESchedule {
    public static func dateYMD(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
    
    private static let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }()
    
    public static func calculateSemesterStart(for referenceDate: Date) throws -> Date {
        if let winterBreak = determineWinterBreak(for: referenceDate) {
            throw winterBreak
        }
        
        if let examPeriod = determineExamPeriod(for: referenceDate) {
            throw examPeriod
        }
        
        if isDateOutOfSemester(referenceDate) {
            throw SemesterState.notInSemester(nextSemesterStart: nextSemesterStart(for: referenceDate))
        }
        
        let year = year(from: referenceDate)
        let winterStart = winterSemesterStart(in: year)
        let summerStart = summerSemesterStart(in: year)
        
        if referenceDate >= summerStart && referenceDate < winterStart {
            return summerStart
        } else if referenceDate >= winterStart {
            return winterStart
        } else {
            return winterSemesterStart(in: year - 1)
        }
    }
    
    private static func determineWinterBreak(for date: Date) -> SemesterState? { // +
        if isFirstDayOfYear(date) {
            let examStart = calendar.date(byAdding: .day, value: 1, to: date)!
            return .winterBreakActive(endOfBreak: date, examPeriodStart: examStart)
        }
        
        let year = year(from: date)
        let breakStart = calendar.date(byAdding: .weekOfYear, value: 13, to: winterSemesterStart(in: year))!
        let breakEnd = dateYMD(year + 1, 1, 1)
        let examStart = calendar.date(byAdding: .day, value: 1, to: breakEnd)!
        
        if date >= breakStart && date < examStart {
            return .winterBreakActive(endOfBreak: breakEnd, examPeriodStart: examStart)
        }
        return nil
    }
    
    private static func isFirstDayOfYear(_ date: Date) -> Bool { // +
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        return (day == 1 && month == 1)
    }
    
    private static func year(from date: Date) -> Int { // +
        calendar.component(.year, from: date)
    }
    
    private static func determineExamPeriod(for date: Date) -> SemesterState? { // +
        let y = year(from: date)
        let examStart = dateYMD(y, 1, 2)
        let summerStart = summerSemesterStart(in: y)
        let examEnd = calendar.date(byAdding: .day, value: -1, to: summerStart)!
        
        if date >= examStart && date <= examEnd {
            return .examPeriodActive(endOfExams: examEnd)
        }
        return nil
    }
    
    private static func summerSemesterStart(in year: Int) -> Date {
        firstMonday(after: year, month: 2, day: 10)
    }
    
    private static func firstMonday(after year: Int, month: Int, day: Int) -> Date {
        let reference = dateYMD(year, month, day)
        let weekday = calendar.component(.weekday, from: reference)
        let offset = (2 - weekday + 7) % 7
        return calendar.date(byAdding: .day, value: offset, to: reference)!
    }
    
    private static func isDateOutOfSemester(_ date: Date) -> Bool {
        let y = year(from: date)
        let juneStart = dateYMD(y, 6, 1)
        let augustEnd = dateYMD(y, 8, 31)
        let septemberStart = dateYMD(y, 9, 1)
        let winterStart = winterSemesterStart(in: y)
        let summerStart = summerSemesterStart(in: y)
        
        let inSummerBreak = (date >= juneStart && date <= augustEnd)
        let inEarlySeptember = (date >= septemberStart && date < winterStart)
        let beforeSummerSemester = (date < summerStart)
        
        return inSummerBreak || inEarlySeptember || beforeSummerSemester
    }
    
    private static func winterSemesterStart(in year: Int) -> Date {
        firstMonday(after: year, month: 9, day: 20)
    }
    
    public static func nextSemesterStart(for date: Date) -> Date {
        winterSemesterStart(in: year(from: date))
    }
    
    public static func calculateWeekNumber(for date: Date) throws -> Int {
        let semesterStart = try calculateSemesterStart(for: date)
        let daysDifference = calendar.dateComponents([.day], from: semesterStart, to: date).day ?? 0
        let weekday = calendar.component(.weekday, from: date)
        let weekOffset = [1, 7].contains(weekday) ? 0 : 1
        return (daysDifference / 7) + weekOffset
    }
}
