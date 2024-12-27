import Foundation
import Combine
import UIKit

open class SemesterViewModelBase: ObservableObject {
    @Published public var displayText: String = ""
    @Published public var textSize: CGFloat = 24.0
    
    public let referenceDate: Date
    private lazy var contentUpdater: ContentUpdater = ContentUpdater(updateCallback: { [weak self] in
        self?.updateContent()
    })
    
    public static let formatter: DateFormatter = createDateFormatter()
    
    public init(referenceDate: Date = Date()) {
        self.referenceDate = referenceDate
        contentUpdater.scheduleDailyUpdate()
        updateContent()
    }
    
    deinit {
        contentUpdater.stopUpdating()
    }
    
    private static func createDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "sk")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateStyle = .medium
        return formatter
    }
    
    private func updateContent() {
        let now = Calendar.current.startOfDay(for: referenceDate)
        do {
            let calculatedWeek = try TUKESchedule.calculateWeekNumber(for: now)
            let successDisplay = getSuccessDisplay(for: calculatedWeek)
            updateUI(display: successDisplay.display, size: successDisplay.size)
        } catch let error as SemesterError {
            handleSemesterError(error)
        } catch {
            updateUI(display: "Nepodarilo sa určiť semester.", size: 24.0)
        }
    }
    
    private func handleSemesterError(_ error: SemesterError) {
        let settings = getDisplaySettings(for: error)
        updateUI(display: settings.display, size: settings.size)
    }
    
    public func updateUI(display: String, size: CGFloat) {
        DispatchQueue.main.async {
            self.displayText = display
            self.textSize = size
        }
    }
    
    open func getDisplaySettings(for error: SemesterError) -> (display: String, size: CGFloat) {
        switch error {
        case .winterBreakActive(let endOfBreak, let examPeriodStart):
            return (
                "Veselé sviatky a veľa šťastia pri príprave na skúšky!\n\nPrestávka do \(Self.formatter.string(from: endOfBreak)).\nSkúšky sa začínajú \(Self.formatter.string(from: examPeriodStart)).",
                24.0
            )
        case .examPeriodActive(let endOfExams):
            return (
                "Veľa šťastia na skúškach!\nSkúšky sa končia \(Self.formatter.string(from: endOfExams))",
                24.0
            )
        case .notInSemester(let nextSemesterStart):
            return (
                "Vidíme sa \(Self.formatter.string(from: nextSemesterStart))!",
                24.0
            )
        }
    }
    
    open func getSuccessDisplay(for week: Int) -> (display: String, size: CGFloat) {
        return ("\(week)", 280.0)
    }
}
