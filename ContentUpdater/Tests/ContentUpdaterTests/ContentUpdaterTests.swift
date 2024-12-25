import XCTest
@testable import ContentUpdater

class MockClock: Clock {
    var currentDate: Date
    
    init(currentDate: Date) {
        self.currentDate = currentDate
    }
}

final class ContentUpdaterTests: XCTestCase {
    
    func testUpdateCallbackIsCalledAtScheduledTime() {
        let expectation = self.expectation(description: "Update callback should be called")
        
        // Set the mock clock to a fixed date
        let fixedDate = Date(timeIntervalSince1970: 0) // Epoch
        let mockClock = MockClock(currentDate: fixedDate)
        
        // Create ContentUpdater with a short interval for testing (e.g., 1 second)
        let contentUpdater = ContentUpdater(clock: mockClock, updateCallback: {
            expectation.fulfill()
        })
        
        contentUpdater.scheduleRecurringUpdate(interval: 1) // 1 second
        
        // Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 2, handler: nil)
        
        contentUpdater.stopUpdating()
    }
    
    func testUpdateCallbackCalledMultipleTimes() {
        let expectation = self.expectation(description: "Update callback should be called twice")
        expectation.expectedFulfillmentCount = 2
        
        let fixedDate = Date(timeIntervalSince1970: 0)
        let mockClock = MockClock(currentDate: fixedDate)
        
        let contentUpdater = ContentUpdater(clock: mockClock, updateCallback: {
            expectation.fulfill()
        })
        
        contentUpdater.scheduleRecurringUpdate(interval: 1) // 1 second
        
        // Wait for both expectations
        waitForExpectations(timeout: 3, handler: nil)
        
        contentUpdater.stopUpdating()
    }
    
    func testStopUpdating() {
        let expectation = self.expectation(description: "Update callback should not be called after stopping")
        expectation.isInverted = true // We expect it NOT to be fulfilled
        
        let fixedDate = Date(timeIntervalSince1970: 0)
        let mockClock = MockClock(currentDate: fixedDate)
        
        let contentUpdater = ContentUpdater(clock: mockClock, updateCallback: {
            expectation.fulfill()
        })
        
        contentUpdater.scheduleRecurringUpdate(interval: 1) // 1 second
        contentUpdater.stopUpdating()
        
        // Wait to ensure callback is not called
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testImmediateUpdate() {
        let expectation = self.expectation(description: "Immediate update callback should be called")
        
        let fixedDate = Date(timeIntervalSince1970: 0)
        let mockClock = MockClock(currentDate: fixedDate)
        
        var callbackCount = 0
        let contentUpdater = ContentUpdater(clock: mockClock) {
            callbackCount += 1
            expectation.fulfill()
        }
        
        contentUpdater.scheduleRecurringUpdate(interval: 86400) // 24 hours
        contentUpdater.scheduleRecurringUpdate(interval: 1) // Override with 1 second for immediate update
        
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(callbackCount, 1, "Callback should have been called once immediately")
        
        contentUpdater.stopUpdating()
    }
}