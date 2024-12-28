import SwiftUI
import WidgetKit
import AppCore

struct WeekWidgetEntryView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCorner:
            AccessoryCornerView(displayState: entry.displayState)
        case .accessoryCircular:
            AccessoryCircularView(displayState: entry.displayState)
        case .accessoryInline:
            AccessoryInlineView(displayState: entry.displayState)
        case .accessoryRectangular:
            AccessoryRectangularView(displayState: entry.displayState)
        case .systemSmall:
            SystemSmallView(displayState: entry.displayState)
        default:
            DefaultWidgetView(displayState: entry.displayState)
        }
    }
    
    private func shortErrorMessage(for state: SemesterState) -> String {
        return state.shortDescription
    }
    
    private func detailedErrorMessage(for state: SemesterState) -> String {
        return state.detailedDescription
    }
}
