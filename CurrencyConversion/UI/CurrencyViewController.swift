//
//  ViewController.swift
//  CurrencyConversion
//
//  Created by CHENCHIAN on 2021/1/21.
//

import UIKit
import RxSwift
import RealmSwift

class CurrencyViewController: UIViewController {

    private let viewModel = CurrencyViewModel()
    private let bag = DisposeBag()

    private let tapOnCurrencyLabel = UITapGestureRecognizer()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.text = "Currency Converter"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.text = "USD"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 58)
        label.textAlignment = .center
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 20
        label.isUserInteractionEnabled = true
        return label
    }()

    private lazy var currencyPicker = CurrencyPickerView()

    private lazy var amountField: UITextField = {
        let textField = UITextField()
        textField.textColor = .darkGray
        textField.font = .systemFont(ofSize: 40)
        textField.textAlignment = .center
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 20
        textField.inputView = CustomKeyboard(target: textField)
        textField.attributedPlaceholder = NSAttributedString(string: "Please enter an amount", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        return textField
    }()

    private let rateGrids: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: 108, height: 130)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 4, bottom: 0, right: 4)
        return collectionView
    }()

    private lazy var noDataView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var noDataIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.startAnimating()
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutUI()
        setupBinding()
    }
    
    // MARK: - UI configurations

    private func layoutUI() {

        // self
        view.backgroundColor = .black

        // titleLabel
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 54).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true

        // currencyLabel
        view.addSubview(currencyLabel)
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        currencyLabel.heightAnchor.constraint(equalToConstant: 68).isActive = true
        currencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        currencyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        // amountField
        view.addSubview(amountField)
        amountField.translatesAutoresizingMaskIntoConstraints = false
        amountField.topAnchor.constraint(equalTo: currencyLabel.bottomAnchor, constant: 20).isActive = true
        amountField.heightAnchor.constraint(equalToConstant: 46).isActive = true
        amountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        amountField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // rateGrids
        view.addSubview(rateGrids)
        rateGrids.register(CurrencyQuoteCell.self, forCellWithReuseIdentifier: CurrencyQuoteCell.cellIdentifier)
        rateGrids.dataSource = viewModel
        rateGrids.delegate = nil
        rateGrids.translatesAutoresizingMaskIntoConstraints = false
        let inset: CGFloat = 12
        rateGrids.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 26).isActive = true
        rateGrids.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset).isActive = true
        rateGrids.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset).isActive = true
        rateGrids.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset).isActive = true
        
        // noDataView
        view.addSubview(noDataView)
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        noDataView.addSubview(noDataIndicator)
        noDataIndicator.translatesAutoresizingMaskIntoConstraints = false
        noDataIndicator.centerXAnchor.constraint(equalTo: noDataView.centerXAnchor).isActive = true
        noDataIndicator.centerYAnchor.constraint(equalTo: noDataView.centerYAnchor).isActive = true
    }
    
    private func setupBinding() {

        // view model
        viewModel.outputs.isReady
            .asDriver()
            .drive(onNext: { [weak self] (isReady) in
                isReady ? self?.hideNoDataView() : self?.showNoDataView()
            }).disposed(by: bag)

        viewModel.outputs.hasUpdate
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.rateGrids.reloadData()
            }).disposed(by: bag)

        // UI components
        currencyLabel.addGestureRecognizer(tapOnCurrencyLabel)
        tapOnCurrencyLabel.rx.event
            .bind { [weak self] _ in self?.showCurrencyPicker(true) }
            .disposed(by: bag)

        currencyPicker.viewModel.outputs.selectedCurrency
            .emit(onNext:{ [weak self] (currency) in
                self?.currencyLabel.text = "\(currency.code)"
                self?.viewModel.inputs.selectCurrency(with: currency.code)
            }).disposed(by: bag)

        currencyPicker.viewModel.outputs.didDismiss
            .emit(onNext: { [weak self] in self?.showCurrencyPicker(false) })
            .disposed(by: bag)

        amountField.rx.controlEvent(.editingDidBegin)
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.amountField.text = ""
            }).disposed(by: bag)

        amountField.rx.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.tryConvert()
            }).disposed(by: bag)
    }

    private func showCurrencyPicker(_ show: Bool) {
        UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve) {
            if show {
                self.amountField.resignFirstResponder()
                self.view.addSubview(self.currencyPicker)
                self.currencyPicker.translatesAutoresizingMaskIntoConstraints = false
                self.currencyPicker.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                self.currencyPicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                self.currencyPicker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                self.currencyPicker.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            } else {
                self.currencyPicker.removeFromSuperview()
            }
        }
    }

    private func showNoDataView() {
        noDataIndicator.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.noDataView.alpha = 1
        }
    }

    private func hideNoDataView() {
        noDataIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3) {
            self.noDataView.alpha = 0
        }
    }
    
    private func tryConvert() {
        if let input = amountField.text, let amount = Double(input) {
            viewModel.inputs.convertRates(with: amount)
        } else {
            // show alert
            let alert = UIAlertController(title: "Input is invalid", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                self.amountField.text = ""
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
}

