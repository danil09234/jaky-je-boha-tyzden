import Foundation
import Combine
import AppCore
import UIKit

public class SemesterViewModel: SemesterViewModelBase {
    public override func getDisplaySettings(for state: SemesterState) -> (display: String, size: CGFloat) {
        switch state {
        case .winterBreakActive(let endOfBreak, let examPeriodStart):
            let message = """
            Veselé sviatky!\n
            Prestávka do \(Self.formatter.string(from: endOfBreak)).
            Skúšky od \(Self.formatter.string(from: examPeriodStart)).
            """
            return (message, 13.0)
        case .examPeriodActive(let endOfExams):
            let message = """
            Veľa šťastia na skúškach!\n
            Skúšky sa končia \(Self.formatter.string(from: endOfExams))
            """
            return (message, 14.0)
        case .notInSemester(let nextSemesterStart):
            let message = "Vidíme sa \(Self.formatter.string(from: nextSemesterStart))!"
            return (message, 20.0)
        }
    }
    
    public override func getSuccessDisplay(for week: Int) -> (display: String, size: CGFloat) {
        return ("\(week)", 150.0)
    }
}
