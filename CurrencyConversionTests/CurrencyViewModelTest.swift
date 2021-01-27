//
//  CurrencyViewModelTest.swift
//  CurrencyConversionTests
//
//  Created by CHENCHIAN on 2021/1/26.
//

@testable import CurrencyConversion
import XCTest
import RealmSwift
import RxSwift

class CurrencyViewModelTest: XCTestCase {

    let viewModel = CurrencyViewModel()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_00_selectCurrency() {
        let exp = expectation(description: "view model can notify updated")
        let bag = DisposeBag()
        let outputs = viewModel.outputs

        outputs.hasUpdate.asSignal().emit(onNext: {
            exp.fulfill()
        }).disposed(by: bag)

        viewModel.inputs.selectCurrency(with: "JPY")

        waitForExpectations(timeout: 3) { (error) in
            if let error = error {
                XCTFail("error: \(error)")
            }
        }
    }
    
    func test_01_selectCurrency() {
        let exp = expectation(description: "view model can notify updated")
        let bag = DisposeBag()
        let outputs = viewModel.outputs

        outputs.hasUpdate.asSignal().emit(onNext: {
            exp.fulfill()
        }).disposed(by: bag)

        viewModel.inputs.convertRates(with: Double.random(in: 0.1...10000.0))

        waitForExpectations(timeout: 3) { (error) in
            if let error = error {
                XCTFail("error: \(error)")
            }
        }
    }
    
    func test_02_updateRealm() {
        var exp: XCTestExpectation? = expectation(description: "isReady can be triggered once realm has been updated")
        let bag = DisposeBag()
        let outputs = viewModel.outputs
        let realm = try! Realm()
        let testCurrency = Currency(code: "PPP", country: "PayPayPlanet")
        let testQuote = Quote(codePair: "PPPJPY", rate: 999.999)

        outputs.isReady.asDriver().drive(onNext: { isReady in
            if isReady {
                exp?.fulfill()
                exp = nil
            }
        }).disposed(by: bag)
        
        try! realm.write {
            realm.add(testCurrency, update: .modified)
            realm.add(testQuote, update: .modified)
        }
        
        waitForExpectations(timeout: 3) { (error) in
            if let error = error {
                XCTFail("error: \(error)")
            }

            try! realm.write {
                realm.delete(testCurrency)
                realm.delete(testQuote)
            }
        }
    }
}
