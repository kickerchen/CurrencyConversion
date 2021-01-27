//
//  CurrencyFetchSchedulerTest.swift
//  CurrencyConversionTests
//
//  Created by CHENCHIAN on 2021/1/26.
//

@testable import CurrencyConversion
import XCTest

class CurrencyFetchSchedulerTest: XCTestCase {

    let scheduler = CurrencyFetchScheduler.shared
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // shouldFetch returns true if time exceeds frequency since the previously fetched time
    func test_00_shouldFetch() {        
        let oneHourAgo: TimeInterval = -3600

        // set lastFetchDate as 1 hour ago (frequency is not exceeded)
        scheduler.lastFetchDate = Date().addingTimeInterval(oneHourAgo)
        XCTAssert(scheduler.shouldFetch == false)

        // set lastFetchDate as 2 hours ago (frequency is exceeded)
        scheduler.lastFetchDate = Date().addingTimeInterval(2 * oneHourAgo)
        XCTAssert(scheduler.shouldFetch == true)
    }
    
    // set lastFetchDate as 1:59:55 ago (5 seconds remains before frequency is exceeded) and test scheduled timer
    func test_01_schedule() {
        let fiveSecondsToTwoHoursAgo = Date().addingTimeInterval(-7195)
        
        scheduler.lastFetchDate = fiveSecondsToTwoHoursAgo
        scheduler.schedule()

        let waitTime: TimeInterval = 10, exp = expectation(description: "wait for timer & fetch api")
        let _ = Timer.scheduledTimer(withTimeInterval: waitTime, repeats: false) { _ in
            exp.fulfill()
        }
        wait(for: [exp], timeout: waitTime)

        XCTAssert(scheduler.lastFetchDate! > fiveSecondsToTwoHoursAgo)
    }
}
