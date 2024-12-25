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

struct ContentView: View {
    private var semesterStart: Date {
        calculateSemesterStart()
    }
    
    @State private var currentWeek: Int?
    @State private var displayText: String = ""

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
        let now = Calendar.current.startOfDay(for: Date())
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

    private func calculateSemesterStart() -> Date {
        let now = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.month, from: now) < 9 ? calendar.component(.year, from: now) - 1 : calendar.component(.year, from: now)
        
        let components = DateComponents(year: year, month: 9, day: 20)
        let initialDate = calendar.date(from: components)!
        
        return calendar.nextDate(after: initialDate, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime)!
    }
}

#Preview {
    ContentView()
}
