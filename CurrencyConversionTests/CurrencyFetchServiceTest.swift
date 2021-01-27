//
//  CurrencyFetchServiceTest.swift
//  CurrencyConversionTests
//
//  Created by CHENCHIAN on 2021/1/26.
//

@testable import CurrencyConversion
import XCTest

class CurrencyFetchServiceTest: XCTestCase {

    let service = CurrencyFetchService.shared
    let scheduler = CurrencyFetchScheduler.shared
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_00_fetchCurrency() {
        let exp = expectation(description: "fetched time will be updated after fetching currency")
        let startTime = Date()

        service.fetchCurrencies()
        let _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
        
        if let lastFetchDate = scheduler.lastFetchDate {
            print("startTime: \(startTime), lastFetchTime: \(lastFetchDate)")
            XCTAssert(lastFetchDate > startTime)
        } else {
            XCTFail("last fetech time is nil")
        }
    }
        
    func test_01_fetchQuote() {
        let exp = expectation(description: "fetched time will be updated after fetching quote")
        let startTime = Date()

        service.fetchQuotes()
        let _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
        
        if let lastFetchDate = scheduler.lastFetchDate {
            print("startTime: \(startTime), lastFetchTime: \(lastFetchDate)")
            XCTAssert(lastFetchDate > startTime)
        } else {
            XCTFail("last fetech time is nil")
        }
    }
}
