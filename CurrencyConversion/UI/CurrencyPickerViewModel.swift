//
//  CurrencyPickerViewModel.swift
//  CurrencyConversion
//
//  Created by CHENCHIAN on 2021/1/23.
//

import RealmSwift
import RxSwift
import RxCocoa

protocol CurrencyPickerVMInputs {
    func reload()
    func dismiss()
}

protocol CurrencyPickerVMOutputs {
    var selectedCurrency: Signal<Currency> { get }
    var didDismiss: Signal<Void> { get }
}

class CurrencyPickerViewModel: NSObject, CurrencyPickerVMInputs, CurrencyPickerVMOutputs {
    var inputs: CurrencyPickerVMInputs { return self }
    var outputs: CurrencyPickerVMOutputs { return self }

    private let selectedCurrencyRelay = PublishRelay<Currency>()
    private let didDismissRelay = PublishRelay<Void>()
    
    private lazy var displayCurrencies = [Currency]()

    private(set) lazy var selectedCurrency = selectedCurrencyRelay.asSignal()
    private(set) lazy var didDismiss = didDismissRelay.asSignal()

    func reload() {
        let realm = try! Realm(), currencyFromDB = realm.objects(Currency.self)
        displayCurrencies = currencyFromDB.map { $0 }.sorted { $0.code < $1.code }
    }
    
    func dismiss() {
        didDismissRelay.accept(())
    }
}

// MARK: - UITableViewDataSource

extension CurrencyPickerViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currency = displayCurrencies[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyPickerView.tableViewCellIdentifier) {
            cell.textLabel?.text = "(\(currency.code)) \(currency.country)"
            cell.textLabel?.numberOfLines = 0
            return cell
        }

        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension CurrencyPickerViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = displayCurrencies[indexPath.row]        
        selectedCurrencyRelay.accept(currency)
        didDismissRelay.accept(())
    }
}
