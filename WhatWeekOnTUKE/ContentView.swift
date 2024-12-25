import SwiftUI

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

func calculateSemesterStart(for referenceDate: Date) -> Date {
    let calendar = Calendar.current
    let referenceYear = calendar.component(.year, from: referenceDate)
    
    func firstMonday(after year: Int, month: Int, day: Int) -> Date {
        let initialDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let weekday = calendar.component(.weekday, from: initialDate)
        let offset = (2 - weekday + 7) % 7
        return calendar.date(byAdding: .day, value: offset, to: initialDate)!
    }
    
    let winterStartCurrentYear = firstMonday(after: referenceYear, month: 9,  day: 20)
    let summerStartCurrentYear = firstMonday(after: referenceYear, month: 2,  day: 10)
    let winterStartNextYear    = firstMonday(after: referenceYear + 1, month: 9,  day: 20)
    
    if referenceDate >= summerStartCurrentYear && referenceDate < winterStartCurrentYear {
        return summerStartCurrentYear
    } else if referenceDate >= winterStartCurrentYear {
        return winterStartCurrentYear
    } else {
        return firstMonday(after: referenceYear - 1, month: 9, day: 20)
    }
}

struct ContentView: View {
    private let referenceDate: Date
    private var semesterStart: Date {
        calculateSemesterStart(for: referenceDate)
    }
    
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
        let now = Calendar.current.startOfDay(for: referenceDate)
        if now >= semesterStart {
            let daysDifference = Calendar.current.dateComponents([.day], from: semesterStart, to: now).day ?? 0
            let weekOffset = [0, 5, 6].contains(Calendar.current.component(.weekday, from: now)) ? 0 : 1
            currentWeek = (daysDifference / 7) + weekOffset

            displayText = "\(currentWeek ?? 0)"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "sk")
            formatter.dateStyle = .medium
            displayText = "Vidíme sa \(formatter.string(from: semesterStart))!"
        }
    }
}

#Preview {
    ContentView()
}
