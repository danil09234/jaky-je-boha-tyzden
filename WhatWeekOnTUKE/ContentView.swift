import SwiftUI

enum SemesterError: Error {
    case notInSemester(nextSemesterStart: Date)
    case examPeriodActive(endOfExams: Date)
    case winterBreakActive(endOfBreak: Date, examPeriodStart: Date)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

private let calendar: Calendar = {
    var cal = Calendar.current
    cal.timeZone = TimeZone(secondsFromGMT: 0)!
    return cal
}()

private func dateYMD(_ year: Int, _ month: Int, _ day: Int) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day))!
}

func firstMonday(after year: Int, month: Int, day: Int) -> Date {
    let initial = dateYMD(year, month, day)
    let weekday = calendar.component(.weekday, from: initial)
    let offset = (2 - weekday + 7) % 7
    return calendar.date(byAdding: .day, value: offset, to: initial)!
}

func nextSemesterStart(after date: Date) -> Date {
    let y = calendar.component(.year, from: date)
    return firstMonday(after: y, month: 9, day: 20)
}

func calculateSemesterStart(for referenceDate: Date) throws -> Date {

    // 1) Identify boundaries of the “current academic year”
    let year = calendar.component(.year, from: referenceDate)
    let winterSemesterStart = firstMonday(after: year, month: 9, day: 20)  // e.g. 9/20 -> first Monday
    let summerSemesterStart = firstMonday(after: year, month: 2, day: 10) // e.g. 2/10 -> first Monday

    // 2) Winter break: 14th week starts on Monday after 13 weeks
    let winterBreakStart = calendar.date(byAdding: .weekOfYear, value: 13, to: winterSemesterStart)!
    let winterBreakEnd = dateYMD(year, 12, 31)

    // 3) Winter exam period: from Jan 1 to day before summer semester
    let examPeriodStart = dateYMD(year, 1, 1)
    let dayBeforeSummerStart = calendar.date(byAdding: .day, value: -1, to: summerSemesterStart)!

    // 4) Summer break: June 1 to August 31
    let juneStart = dateYMD(year, 6, 1)
    let augEnd    = dateYMD(year, 8, 31)
    
    // 5) Early September: Sept 1 until winterSemesterStart
    let septStart = dateYMD(year, 9, 1)
    
    // -- Check for winter break
    if referenceDate >= winterBreakStart && referenceDate <= winterBreakEnd {
        let examPeriodStart = Calendar.current.date(byAdding: .day, value: 1, to: winterBreakEnd)!
        throw SemesterError.winterBreakActive(endOfBreak: winterBreakEnd, examPeriodStart: examPeriodStart)
    }

    // -- Check for winter exam period
    if referenceDate >= examPeriodStart && referenceDate <= dayBeforeSummerStart {
        throw SemesterError.examPeriodActive(endOfExams: dayBeforeSummerStart)
    }

    // -- Check for summer break or early September or before summer semester
    if (referenceDate >= juneStart && referenceDate <= augEnd)
        || (referenceDate >= septStart && referenceDate < winterSemesterStart)
        || (referenceDate < summerSemesterStart) {
        throw SemesterError.notInSemester(nextSemesterStart: nextSemesterStart(after: referenceDate))
    }

    // 6) If not in break/exams, we are presumably in a semester.
    //    Decide if it’s summer or winter, based on referenceDate.
    //    - If referenceDate >= summerSemesterStart and < winterSemesterStart => summer
    //    - If referenceDate >= winterSemesterStart => winter
    //    - Else => must be the winter from previous year
    if referenceDate >= summerSemesterStart && referenceDate < winterSemesterStart {
        return summerSemesterStart
    } else if referenceDate >= winterSemesterStart {
        return winterSemesterStart
    } else {
        // Must be the previous winter
        return firstMonday(after: year - 1, month: 9, day: 20)
    }
}

private func firstMondayAfterNewYear(year: Int) -> Date {
    return firstMonday(after: year, month: 1, day: 1)
}

struct ContentView: View {
    private let referenceDate: Date
    @State private var currentWeek: Int?
    @State private var displayText: String = ""
    
    init(referenceDate: Date = Date()) {
        self.referenceDate = referenceDate
    }
    
    var body: some View {
        VStack {
            Text(displayText)
                .font(.custom("Roboto-Bold", size: currentWeek != nil ? 280 : 50))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#222"))
        .onAppear(perform: updateWeek)
    }

    private func updateWeek() {
        let now = calendar.startOfDay(for: referenceDate)
        do {
            let semesterStart = try calculateSemesterStart(for: now)
            let daysDifference = calendar.dateComponents([.day], from: semesterStart, to: now).day ?? 0
            let weekday = calendar.component(.weekday, from: now)
            let weekOffset = [0, 5, 6].contains(weekday) ? 0 : 1
            currentWeek = (daysDifference / 7) + weekOffset
            displayText = "\(currentWeek ?? 0)"
        } catch SemesterError.winterBreakActive(let endOfBreak, let examPeriodStart) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "sk")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateStyle = .medium
            displayText = "Veselé sviatky a veľa šťastia pri príprave na skúšky! Prestávka do \(formatter.string(from: endOfBreak)). Skúškové začínajú \(formatter.string(from: examPeriodStart))."
        } catch SemesterError.examPeriodActive(let endOfExams) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "sk")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateStyle = .medium
            displayText = "Veľa šťastia na skúškach! Skúškové končia \(formatter.string(from: endOfExams))"
        } catch SemesterError.notInSemester(let nextSemesterStart) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "sk")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateStyle = .medium
            displayText = "Vidíme sa \(formatter.string(from: nextSemesterStart))!"
        } catch {
            displayText = "Nepodarilo sa určiť semester."
        }
    }
}

#Preview {
    ContentView()
}
