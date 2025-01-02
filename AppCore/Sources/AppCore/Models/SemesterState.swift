import Foundation
import SwiftUI

public enum SemesterState: Error, Hashable {
    case winterBreakActive(endOfBreak: Date, examPeriodStart: Date)
    case examPeriodActive(endOfExams: Date)
    case summerBreakActive(winterSemesterStart: Date)
}
