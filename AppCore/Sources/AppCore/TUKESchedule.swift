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
        let startOfReferenceDate = calendar.startOfDay(for: referenceDate)
        if let winterBreak = determineWinterBreak(for: startOfReferenceDate) {
            throw winterBreak
        }
        
        if let examPeriod = determineExamPeriod(for: startOfReferenceDate) {
            throw examPeriod
        }
        
        if isDateOutOfSemester(startOfReferenceDate) {
            throw SemesterState.summerBreakActive(winterSemesterStart: winterSemesterStart(in: year(from: startOfReferenceDate)))
        }
        
        let year = year(from: startOfReferenceDate)
        let winterStart = winterSemesterStart(in: year)
        let summerStart = summerSemesterStart(in: year)
        
        if startOfReferenceDate >= summerStart && startOfReferenceDate < winterStart {
            return summerStart
        } else if startOfReferenceDate >= winterStart {
            return winterStart
        } else {
            return winterSemesterStart(in: year - 1)
        }
    }
    
    private static func determineWinterBreak(for date: Date) -> SemesterState? {
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
    
    private static func isFirstDayOfYear(_ date: Date) -> Bool {
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        return (day == 1 && month == 1)
    }
    
    private static func year(from date: Date) -> Int {
        calendar.component(.year, from: date)
    }
    
    private static func determineExamPeriod(for date: Date) -> SemesterState? {
        let y = year(from: date)
        
        // Winter exam period: 01.02 until day before summer semester starts
        let winterExamStart = dateYMD(y, 1, 2)
        let summerStart = summerSemesterStart(in: y)
        let winterExamEnd = calendar.date(byAdding: .day, value: -1, to: summerStart)!
        if date >= winterExamStart && date <= winterExamEnd {
            return .examPeriodActive(endOfExams: winterExamEnd)
        }
        
        // Summer exam period: ~13 weeks after summer start until June 1
        let summerExamStart = calendar.date(byAdding: .weekOfYear, value: 13, to: summerStart)!
        let summerExamEnd = dateYMD(y, 5, 31)
        if date >= summerExamStart && date <= summerExamEnd {
            return .examPeriodActive(endOfExams: summerExamEnd)
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
    
    public static func calculateWeekNumber(for date: Date) throws -> Int {
        let semesterStart = try calculateSemesterStart(for: date)
        let daysDifference = calendar.dateComponents([.day], from: semesterStart, to: date).day ?? 0
        return (daysDifference / 7) + 1
    }
}
