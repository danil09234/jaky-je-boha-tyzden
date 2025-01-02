import Foundation
import Combine
import UIKit

open class SemesterViewModel: ObservableObject {
    @Published public var displayState: DisplayState = .displayNone
    
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
    
    deinit {
        contentUpdater.stopUpdating()
    }
    
    private func updateContent() {
        displayState = fetchDisplayState(for: referenceDate)
    }
    
    private func fetchDisplayState(for date: Date) -> DisplayState {
        do {
            let week = try TUKESchedule.calculateWeekNumber(for: date)
            return .week(week)
        } catch let state as SemesterState {
            return .specialCase(state)
        } catch {
            return .displayNone
        }
    }
}
