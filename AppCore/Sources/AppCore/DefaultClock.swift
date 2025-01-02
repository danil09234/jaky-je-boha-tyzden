import Foundation

public class DefaultClock: Clock {
    public var currentDate: Date {
        return Date()
    }
    
    public init() {}
}
