import XCTest
@testable import AppCore

final class TUKEScheduleTests: XCTestCase {
    
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCalculateSemesterStart() {
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
            
            do {
                let calculatedDate = try TUKESchedule.calculateSemesterStart(for: referenceDate)
                XCTAssertEqual(
                    calendar.startOfDay(for: calculatedDate),
                    calendar.startOfDay(for: expectedDate),
                    "Failed for input \(testCase.input)"
                )
            } catch {
                XCTFail("Unexpected error for input \(testCase.input): \(error)")
            }
        }
    }

    func testOutOfSemesterPeriods() {
        let testCases: [(input: String, description: String)] = [
            ("2023-07-01", "Summer period"),
            ("2024-06-01", "Early June"),
            ("2025-08-15", "Mid August"),
            ("2023-09-01", "Early September before semester")
        ]
        
        for testCase in testCases {
            let referenceDate = isoStringToDate(testCase.input)
            XCTAssertThrowsError(
                try TUKESchedule.calculateSemesterStart(for: referenceDate),
                "Should throw for \(testCase.description) (\(testCase.input))"
            ) { error in
                guard case .summerBreakActive(let winterSemesterStart) = error as? SemesterState else {
                    return XCTFail("Wrong error thrown for \(testCase.description) (\(testCase.input))")
                }
                XCTAssertTrue(winterSemesterStart > referenceDate, "Next semester start should be in the future for \(testCase.description) (\(testCase.input))")
            }
        }
    }
    
    func testWinterBreakWithTestCases() {
        let testCases: [(input: String, expectedEnd: String, expectedExamPeriodStart: String, description: String)] = [
            // 2021 break
            ("2021-12-20", "2022-01-01", "2022-01-02", "Start day of 2021 break"),
            ("2021-12-27", "2022-01-01", "2022-01-02", "In the middle of 2021 break"),
            ("2022-01-01", "2022-01-01", "2022-01-02", "Last day of 2021 break"),
            // 2022 break
            ("2022-12-26", "2023-01-01", "2023-01-02", "Start day of 2022 break"),
            ("2022-12-27", "2023-01-01", "2023-01-02", "In the middle of 2022 break"),
            ("2023-01-01", "2023-01-01", "2023-01-02", "Last day of 2022 break"),
            // 2023 break
            ("2023-12-25", "2024-01-01", "2024-01-02", "Start day of 2023 break"),
            ("2023-12-27", "2024-01-01", "2024-01-02", "In the middle of 2023 break"),
            ("2024-01-01", "2024-01-01", "2024-01-02", "Last day of 2023 break"),
            // 2024 break
            ("2024-12-23", "2025-01-01", "2025-01-02", "Start day of 2024 break"),
            ("2024-12-27", "2025-01-01", "2025-01-02", "In the middle of 2024 break"),
            ("2025-01-01", "2025-01-01", "2025-01-02", "Last day of 2024 break")
        ]
        
        for testCase in testCases {
            let ref = isoStringToDate(testCase.input)
            let expectedEnd = isoStringToDate(testCase.expectedEnd)
            let expectedExamStart = isoStringToDate(testCase.expectedExamPeriodStart)
            
            XCTAssertThrowsError(
                try TUKESchedule.calculateSemesterStart(for: ref),
                "Should be winterBreakActive for \(testCase.description) (\(testCase.input))"
            ) { error in
                guard case .winterBreakActive(let endOfBreak, let examPeriodStart) = error as? SemesterState else {
                    return XCTFail("Wrong error thrown for winter break \(testCase.input): \(error)")
                }
                XCTAssertEqual(endOfBreak, expectedEnd, "Winter break end mismatch for \(testCase.description) (\(testCase.input))")
                XCTAssertEqual(examPeriodStart, expectedExamStart, "Exam period start mismatch for \(testCase.description) (\(testCase.input))")
            }
        }
        
        let safeDates: [(input: String, description: String)] = [
            ("2021-12-19", "Day before 2021 break"),
            ("2022-12-25", "Day before 2022 break"),
            ("2023-12-24", "Day before 2023 break"),
            ("2024-12-22", "Day before 2024 break"),
        ]
        for safeDate in safeDates {
            let ref = isoStringToDate(safeDate.input)
            XCTAssertNoThrow(
                try TUKESchedule.calculateSemesterStart(for: ref),
                "Should not be winterBreakActive for \(safeDate.description) (\(safeDate.input))"
            )
        }
    }

    func testExamPeriodWithTestCases() {
        let testCases: [(input: String, endOfExams: String, description: String)] = [
            // 2022 exam period
            ("2022-01-02", "2022-02-13", "Start of 2022 exam period"),
            ("2022-01-15", "2022-02-13", "Middle of 2022 exam period"),
            ("2022-02-13", "2022-02-13", "Last day of 2022 exam period"),
            // 2023 exam period
            ("2023-01-02", "2023-02-12", "Start of 2023 exam period"),
            ("2023-01-15", "2023-02-12", "Middle of 2023 exam period"),
            ("2023-02-12", "2023-02-12", "Last day of 2023 exam period"),
            // 2024 exam period
            ("2024-01-02", "2024-02-11", "Start of 2024 exam period"),
            ("2024-01-15", "2024-02-11", "Middle of 2024 exam period"),
            ("2024-02-11", "2024-02-11", "Last day of 2024 exam period"),
            // 2025 exam period
            ("2025-01-02", "2025-02-09", "Start of 2025 exam period"),
            ("2025-01-15", "2025-02-09", "Middle of 2025 exam period"),
            ("2025-02-09", "2025-02-09", "Last day of 2025 exam period")
        ]
        
        for testCase in testCases {
            let ref = isoStringToDate(testCase.input)
            do {
                _ = try TUKESchedule.calculateSemesterStart(for: ref)
                XCTFail("Expected examPeriodActive for \(testCase.description) (\(testCase.input))")
            } catch SemesterState.examPeriodActive(let endOfExams) {
                let expectedEnd = isoStringToDate(testCase.endOfExams)
                XCTAssertEqual(
                    endOfExams,
                    expectedEnd,
                    "Exam end mismatch for \(testCase.description) (\(testCase.input))"
                )
            } catch {
                XCTFail("Wrong error for \(testCase.description) (\(testCase.input)): \(error)")
            }
        }
        
        let safeCases: [(input: String, description: String)] = [
            ("2023-02-13", "Day after 2023 exam period ends"),
            ("2024-02-12", "Day after 2024 exam period ends"),
            ("2025-02-10", "Day after 2025 exam period ends")
        ]
        
        for safeCase in safeCases {
            let ref = isoStringToDate(safeCase.input)
            XCTAssertNoThrow(
                try TUKESchedule.calculateSemesterStart(for: ref),
                "Should not be examPeriodActive for \(safeCase.description) (\(safeCase.input))"
            )
        }
    }

    func testSummerBreak() {
        let ref = dateYMD(2023, 7, 15)
        XCTAssertThrowsError(try TUKESchedule.calculateSemesterStart(for: ref)) { error in
            guard case .summerBreakActive(let winterSemesterStart) = error as? SemesterState else {
                return XCTFail("Expected notInSemester, got \(error)")
            }
            XCTAssertTrue(winterSemesterStart > ref, "Next semester should be in the future")
        }
    }

    func testEarlySeptember() {
        let ref = dateYMD(2023, 9, 10)
        XCTAssertThrowsError(try TUKESchedule.calculateSemesterStart(for: ref)) { error in
            guard case .summerBreakActive(let winterSemesterStart) = error as? SemesterState else {
                return XCTFail("Expected notInSemester, got \(error)")
            }
            XCTAssertEqual(winterSemesterStart, dateYMD(2023, 9, 25), "Next semester mismatch")
        }
    }

    func testValidSummerSemester() {
        let ref = dateYMD(2023, 3, 1)
        do {
            let result = try TUKESchedule.calculateSemesterStart(for: ref)
            XCTAssertEqual(result, dateYMD(2023, 2, 13), "Should be 2/13/2023 for summer start")
        } catch {
            XCTFail("Unexpected error for valid summer semester: \(error)")
        }
    }

    func testValidWinterSemester() {
        let ref = dateYMD(2023, 10, 1)
        do {
            let result = try TUKESchedule.calculateSemesterStart(for: ref)
            XCTAssertEqual(result, dateYMD(2023, 9, 25), "Should be 9/25/2023 for winter start")
        } catch {
            XCTFail("Unexpected error for valid winter semester: \(error)")
        }
    }
    
    private func dateYMD(_ year: Int, _ month: Int, _ day: Int) -> Date {
        let dc = DateComponents(timeZone: TimeZone(secondsFromGMT: 0), year: year, month: month, day: day)
        guard let date = calendar.date(from: dc) else {
            fatalError("Invalid date components: \(year)-\(month)-\(day)")
        }
        return date
    }
    
    func testKnownWeeksAndStartOfSemester2024() {
        let testCases: [(input: String, expectedWeek: Int)] = [
            ("2024-09-23", 1),
            ("2024-09-24", 1),
            ("2024-09-25", 1),
            ("2024-09-26", 1),
            ("2024-09-27", 1),
            ("2024-09-28", 1),
            ("2024-09-29", 1),
            ("2024-09-30", 2),
            ("2024-10-01", 2),
            ("2024-10-02", 2),
            ("2024-10-03", 2),
            ("2024-10-04", 2),
            ("2024-10-05", 2),
            ("2024-10-06", 2),
            ("2024-10-07", 3),
            ("2024-10-08", 3),
            ("2024-10-09", 3),
            ("2024-10-10", 3),
            ("2024-10-11", 3),
            ("2024-10-12", 3),
            ("2024-10-13", 3)
        ]
        
        let expectedSemesterStart = dateYMD(2024, 9, 23)
        
        for testCase in testCases {
            let referenceDate = isoStringToDate(testCase.input)
            do {
                let semesterStart = try TUKESchedule.calculateSemesterStart(for: referenceDate)
                XCTAssertEqual(semesterStart, expectedSemesterStart, "Failed for date \(testCase.input)")
                let week = calendar.component(.weekOfYear, from: referenceDate) - calendar.component(.weekOfYear, from: semesterStart) + 1
                XCTAssertEqual(week, testCase.expectedWeek, "Week mismatch for date \(testCase.input)")
            } catch {
                XCTFail("Unexpected error for date \(testCase.input): \(error)")
            }
        }
    }
}
