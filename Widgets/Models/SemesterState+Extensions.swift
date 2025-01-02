import SwiftUI
import AppCore

public extension SemesterState {
    var iconName: String {
        switch self {
        case .winterBreakActive:
            return "snowflake"
        case .examPeriodActive:
            return "book.closed"
        case .summerBreakActive:
            return "sun.max"
        }
    }
    
    var color: Color {
        switch self {
        case .winterBreakActive:
            return .blue
        case .examPeriodActive:
            return .green
        case .summerBreakActive:
            return .orange
        }
    }
    
    var shortDescription: String {
        switch self {
        case .winterBreakActive:
            return "Prestávka"
        case .examPeriodActive:
            return "Skúšky"
        case .summerBreakActive:
            return "Prestávka"
        }
    }
    
    var detailedDescription: String {
        let dateFormatter = createDateFormatter()
        
        switch self {
        case .winterBreakActive(_, let examPeriodStart):
            return "Skúškové začína\n\(dateFormatter.string(from: examPeriodStart))"
        case .examPeriodActive(let endOfExams):
            return "Skúškové končí\n\(dateFormatter.string(from: endOfExams))"
        case .summerBreakActive(let winterSemesterStart):
            return "Vidíme sa\n\(dateFormatter.string(from: winterSemesterStart))!"
        }
    }
}
