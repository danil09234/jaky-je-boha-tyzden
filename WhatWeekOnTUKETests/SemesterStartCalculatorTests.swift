import XCTest
@testable import WhatWeekOnTUKE

final class SemesterStartCalculatorTests: XCTestCase {
    
    func testCalculateSemesterStart() {
        let calendar = Calendar.current
        let testCases: [(input: String, expected: String)] = [
            // Winter
            ("2020-10-01", "2020-09-21"),
            ("2021-10-01", "2021-09-20"),
            ("2022-10-01", "2022-09-26"),
            ("2023-10-01", "2023-09-25"),
            ("2024-10-01", "2024-09-23"),
            // Summer
            ("2021-03-01", "2021-02-15"),
            ("2022-03-01", "2022-02-14"),
            ("2023-03-01", "2023-02-13"),
            ("2024-03-01", "2024-02-12"),
            ("2025-03-01", "2025-02-10")
        ]
        
        for testCase in testCases {
            let referenceDate = isoStringToDate(testCase.input)
            let expectedDate = isoStringToDate(testCase.expected)
            let calculatedDate = calculateSemesterStart(for: referenceDate)
            XCTAssertEqual(calendar.startOfDay(for: calculatedDate),
                           calendar.startOfDay(for: expectedDate),
                           "Failed for input \(testCase.input)")
        }
    }
    
    private func isoStringToDate(_ isoString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: isoString)!
    }
}
