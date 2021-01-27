//
//  CurrencyPickerView.swift
//  CurrencyConversion
//
//  Created by CHENCHIAN on 2021/1/23.
//

import UIKit
import RxSwift

class CurrencyPickerView: UIView {

    static let tableViewCellIdentifier = "CurrencyPickerTableViewCell"

    let viewModel = CurrencyPickerViewModel()

    private let bag = DisposeBag()

    private let backgroundTap = UITapGestureRecognizer()

    private lazy var background: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4.0
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorColor = .lightGray
        tableView.layer.cornerRadius = 4.0
        return tableView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Select a currency"
        label.font = .systemFont(ofSize: 18)
        return label
    }()

    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        backgroundColor = .clear

        layoutUI()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        viewModel.inputs.reload()
    }

    // MARK: - UI configurations

    private func layoutUI() {

        // background
        addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        background.topAnchor.constraint(equalTo: topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        background.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        // container
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(equalTo: background.topAnchor, constant: 30).isActive = true
        container.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -40).isActive = true
        container.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 36).isActive = true
        container.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -36).isActive = true

        // label
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18).isActive = true

        // separatorLine
        container.addSubview(separatorLine)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLine.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        separatorLine.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        
        // tableView
        container.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CurrencyPickerView.tableViewCellIdentifier)
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: container.topAnchor, constant: 100).isActive = true
        tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        tableView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: container.widthAnchor).isActive = true
    }
    
    private func setupBinding() {
        
        // tap on background
        background.addGestureRecognizer(backgroundTap)
        backgroundTap.rx.event.bind { [weak self] _ in
            self?.viewModel.inputs.dismiss()
        }.disposed(by: bag)
    }
}
