import SwiftUI
import AppCore

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
                .font(.custom("Roboto-Bold", size: currentWeek != nil ? 280 : 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#222"))
        .onAppear(perform: updateWeek)
    }

    private func updateWeek() {
        let now = TUKESchedule.dateYMD(
            Calendar.current.component(.year, from: referenceDate),
            Calendar.current.component(.month, from: referenceDate),
            Calendar.current.component(.day, from: referenceDate)
        )
        do {
            let semesterStart = try TUKESchedule.calculateSemesterStart(for: now)
            let daysDifference = Calendar.current.dateComponents([.day], from: semesterStart, to: now).day ?? 0
            let weekday = Calendar.current.component(.weekday, from: now)
            let weekOffset = [0, 5, 6].contains(weekday) ? 0 : 1
            currentWeek = (daysDifference / 7) + weekOffset
            displayText = "\(currentWeek ?? 0)"
        } catch SemesterError.winterBreakActive(let endOfBreak, let examPeriodStart) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "sk")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateStyle = .medium
            displayText = "Veselé sviatky a veľa šťastia pri príprave na skúšky! \nPrestávka do \(formatter.string(from: endOfBreak)). \nSkúšky sa začínajú \(formatter.string(from: examPeriodStart))."
        } catch SemesterError.examPeriodActive(let endOfExams) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "sk")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateStyle = .medium
            displayText = "Veľa šťastia na skúškach! \nSkúšky sa končia \(formatter.string(from: endOfExams))"
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
