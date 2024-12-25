import Foundation
import Combine
import TUKESchedule
import ContentUpdater

class SemesterViewModel: ObservableObject {
    @Published var displayText: String = ""
    @Published var textSize: CGFloat = 14.0
    
    private let referenceDate: Date
    private lazy var contentUpdater: ContentUpdater = ContentUpdater(updateCallback: { [weak self] in
        self?.updateContent()
    })
    
    init(referenceDate: Date = Date()) {
        self.referenceDate = referenceDate
        self.contentUpdater.scheduleDailyUpdate()
        updateContent()
    }
    
    deinit {
        contentUpdater.stopUpdating()
    }
    
    private func updateContent() {
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
            let calculatedWeek = (daysDifference / 7) + weekOffset
            DispatchQueue.main.async {
                self.displayText = "\(calculatedWeek)"
                self.textSize = 180
            }
        } catch SemesterError.winterBreakActive(let endOfBreak, let examPeriodStart) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "sk")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateStyle = .medium
            DispatchQueue.main.async {
                self.displayText = """
                Veselé sviatky a veľa šťastia pri príprave na skúšky!
                Prestávka do \(formatter.string(from: endOfBreak)).
                Skúšky sa začínajú \(formatter.string(from: examPeriodStart)).
                """
                self.textSize = 13
            }
        } catch SemesterError.examPeriodActive(let endOfExams) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "sk")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateStyle = .medium
            DispatchQueue.main.async {
                self.displayText = "Veľa šťastia na skúškach! \nSkúšky sa končia \(formatter.string(from: endOfExams))"
                self.textSize = 14
            }
        } catch SemesterError.notInSemester(let nextSemesterStart) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "sk")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateStyle = .medium
            DispatchQueue.main.async {
                self.displayText = "Vidíme sa \n\(formatter.string(from: nextSemesterStart))!"
                self.textSize = 20
            }
        } catch {
            DispatchQueue.main.async {
                self.displayText = "Nepodarilo sa určiť semester."
                self.textSize = 14
            }
        }
    }
}
