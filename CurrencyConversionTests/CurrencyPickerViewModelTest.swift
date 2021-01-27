//
//  CurrencyPickerViewModelTest.swift
//  CurrencyConversionTests
//
//  Created by CHENCHIAN on 2021/1/26.
//

@testable import CurrencyConversion
import XCTest
import RxSwift

class CurrencyPickerViewModelTest: XCTestCase {

    let viewModel = CurrencyPickerViewModel()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_00_dismiss() {
        let exp = expectation(description: "view model can send dismiss signal")
        let bag = DisposeBag()
        let outputs = viewModel.outputs

        outputs.didDismiss.asSignal().emit(onNext: {
            exp.fulfill()
        }).disposed(by: bag)

        viewModel.inputs.dismiss()

        waitForExpectations(timeout: 3) { (error) in
            if let error = error {
                XCTFail("error: \(error)")
            }
        }
    }
}
