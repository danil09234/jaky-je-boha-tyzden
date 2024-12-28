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

    public init(referenceDate: Date) {
        self.referenceDate = referenceDate
        updateContent()
    }
    
    public init() {
        self.referenceDate = Date()
        contentUpdater.scheduleDailyUpdate()
        updateContent()
    }
    
    public static let formatter: DateFormatter = createDateFormatter()
    
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
        do {
            let calculatedWeek = try TUKESchedule.calculateWeekNumber(for: referenceDate)
            let successDisplay = getSuccessDisplay(for: calculatedWeek)
            updateUI(display: successDisplay.display, size: successDisplay.size)
        } catch let state as SemesterState {
            handleSemesterState(state)
        } catch {
            updateUI(display: "Nepodarilo sa určiť semester.", size: 24.0)
        }
    }
    
    private func handleSemesterState(_ state: SemesterState) {
        let settings = getDisplaySettings(for: state)
        updateUI(display: settings.display, size: settings.size)
    }
    
    public func updateUI(display: String, size: CGFloat) {
        DispatchQueue.main.async {
            self.displayText = display
            self.textSize = size
        }
    }
    
    open func getDisplaySettings(for state: SemesterState) -> (display: String, size: CGFloat) {
        switch state {
        case .winterBreakActive(let endOfBreak, let examPeriodStart):
            return (
                """
                Veselé sviatky!\n
                Prestávka do \(Self.formatter.string(from: endOfBreak)).
                Skúšky od \(Self.formatter.string(from: examPeriodStart)).
                """,
                24.0
            )
        case .examPeriodActive(let endOfExams):
            return (
                """
                Veľa šťastia na skúškach!\n
                Skúšky sa končia \(Self.formatter.string(from: endOfExams)).
                """,
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
