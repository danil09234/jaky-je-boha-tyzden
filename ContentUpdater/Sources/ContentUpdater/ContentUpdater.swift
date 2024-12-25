import Foundation

public protocol Clock {
    var currentDate: Date { get }
}

public class DefaultClock: Clock {
    public var currentDate: Date {
        return Date()
    }
    
    public init() {}
}

public class ContentUpdater {
    private let clock: Clock
    private let updateCallback: () -> Void
    private var timer: Timer?
    
    public init(clock: Clock = DefaultClock(), updateCallback: @escaping () -> Void) {
        self.clock = clock
        self.updateCallback = updateCallback
    }

    /// Schedules a recurring update based on the specified time interval.
    public func scheduleRecurringUpdate(interval: TimeInterval) {
        // Invalidate existing timer if any
        timer?.invalidate()
        
        // Schedule the timer to fire repeatedly at the given interval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateCallback()
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    /// Schedules a daily update to fire at midnight.
    public func scheduleDailyUpdate() {
        // Calculate the time interval until the next midnight
        let now = clock.currentDate
        let calendar = Calendar.current
        guard let nextMidnight = calendar.nextDate(after: now, matching: DateComponents(hour:0, minute:0, second:0), matchingPolicy: .nextTime) else { return }
        
        // Invalidate existing timer if any
        timer?.invalidate()
        
        // Schedule the timer to fire at midnight and repeat every 24 hours
        timer = Timer(fire: nextMidnight, interval: 86400, repeats: true) { [weak self] _ in
            self?.updateCallback()
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    public func stopUpdating() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }
}
