import SwiftUI
import AppCore
import Foundation

struct MainPage: View {
    private static var dateFormatter = createDateFormatter()
    
    private func getInitialDate(for date: Date) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return endOfDay
    }
    
    var body: some View {
        TimelineView(.periodic(from: self.getInitialDate(for: Date()), by: 1)) {context in
            MainPageContent(
                dateFormatter: MainPage.dateFormatter,
                displayState: fetchDisplayState(for: context.date)
            )
        }
    }
}

#Preview {
    MainPage()
}
