import SwiftUI
import AppCore

public extension SemesterState {
    var iconName: String {
        switch self {
        case .winterBreakActive:
            return "snowflake"
        case .examPeriodActive:
            return "book.closed"
        case .notInSemester:
            return "sun.max"
        }
    }
    
    var color: Color {
        switch self {
        case .winterBreakActive:
            return .blue
        case .examPeriodActive:
            return .green
        case .notInSemester:
            return .orange
        }
    }
    
    var shortDescription: String {
        switch self {
        case .winterBreakActive:
            return "Prestávka"
        case .examPeriodActive:
            return "Skúšky"
        case .notInSemester:
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
        case .notInSemester(let nextSemesterStart):
            return "Vidíme sa\n\(dateFormatter.string(from: nextSemesterStart))!"
        }
    }
}
