import SwiftUI
import AppCore
import Foundation

struct MainPageContent: View {
    var dateFormatter: DateFormatter
    var displayState: DisplayState

    var body: some View {
        MainContainer {
            switch displayState {
            case .week(let week):
                Week(week: week)
            case .specialCase(let semesterState):
                switch semesterState {
                case .winterBreakActive(let endOfBreak, let examPeriodStart):
                    WinterBreak(
                        endOfBreak: dateFormatter.string(from: endOfBreak),
                        examPeriodStart: dateFormatter.string(from: examPeriodStart)
                    )
                case .examPeriodActive(let endOfExams):
                    ExamPeriod(
                        endOfExams: dateFormatter.string(from: endOfExams)
                    )
                case .summerBreakActive(let winterSemesterStart):
                    SummerBreak(
                        winterSemesterStart: dateFormatter.string(from: winterSemesterStart)
                    )
                case _:
                    DisplayNone()
                }
            case .displayNone:
                DisplayNone()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    private struct PreviewData {
        let displayName: String
        let timestamp: Double
    }
    
    private static let dateFormatter = createDateFormatter()
    
    private static let previewTimelines: [PreviewData] = [
        PreviewData(displayName: "Summer Break", timestamp: 1720569600),
        PreviewData(displayName: "Winter Semester - Week 6", timestamp: 1731196800),
        PreviewData(displayName: "Winter Break", timestamp: 1735325027),
        PreviewData(displayName: "Exam Period", timestamp: 1735689600),
        PreviewData(displayName: "Summer Semester - Week 14", timestamp: 1747267200)
    ]
    
    static var previews: some View {
        Group {
            ForEach(previewTimelines, id: \.displayName) { preview in
                MainPageContent(
                    dateFormatter: ContentView_Previews.dateFormatter,
                    displayState: fetchDisplayState(for: Date(timeIntervalSince1970: preview.timestamp))
                )
                .previewDisplayName(preview.displayName)
            }
            
            MainPageContent(dateFormatter: ContentView_Previews.dateFormatter, displayState: fetchDisplayState(for: Date()))
                .previewDisplayName("Default")
        }
    }
}
