//
//  CustomKeyboard.swift
//  CurrencyConversion
//
//  Created by CHENCHIAN on 2021/1/23.
//

import UIKit

class DigitButton: UIButton {
    var digit: Int = 0
}

class CustomKeyboard: UIView {

    weak var target: UIKeyInput?

    lazy var numericButtons: [DigitButton] = (0...9).map {
        let button = DigitButton(type: .system)
        button.digit = $0
        button.setTitle("\($0)", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.accessibilityTraits = [.keyboardKey]
        button.addTarget(self, action: #selector(didTapDigitButton(_:)), for: .touchUpInside)
        return button
    }

    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⌫", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.accessibilityTraits = [.keyboardKey]
        button.addTarget(self, action: #selector(didTapDeleteButton(_:)), for: .touchUpInside)
        return button
    }()

    lazy var decimalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(".", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.accessibilityTraits = [.keyboardKey]
        button.addTarget(self, action: #selector(didTapDecimalButton(_:)), for: .touchUpInside)
        return button
    }()

    lazy var convertButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("convert", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.accessibilityTraits = [.keyboardKey]
        button.addTarget(self, action: #selector(didTapConvertButton(_:)), for: .touchUpInside)
        return button
    }()

    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⤓", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.accessibilityTraits = [.keyboardKey]
        button.addTarget(self, action: #selector(didTapDismissButton(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializers

    init(target: UIKeyInput) {
        self.target = target
        super.init(frame: .zero)
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI configurations
    
    private func layoutUI() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addButtons()
    }

    private func addButtons() {
        let stackView = createStackView(axis: .vertical)
        stackView.frame = bounds
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(stackView)

        for row in 0 ..< 3 {
            let subStackView = createStackView(axis: .horizontal)
            stackView.addArrangedSubview(subStackView)

            for column in 0 ..< 3 {
                subStackView.addArrangedSubview(numericButtons[row * 3 + column + 1])
            }
        }

        let subStackView = createStackView(axis: .horizontal)
        stackView.addArrangedSubview(subStackView)

        subStackView.addArrangedSubview(decimalButton)
        subStackView.addArrangedSubview(numericButtons[0])
        subStackView.addArrangedSubview(deleteButton)

        let subStackView2 = createStackView(axis: .horizontal)
        stackView.addArrangedSubview(subStackView2)
        subStackView2.addArrangedSubview(convertButton)
        subStackView2.addArrangedSubview(dismissButton)
    }

    private func createStackView(axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }
    
    // MARK: - Actions
    
    @objc func didTapDigitButton(_ sender: DigitButton) {
        target?.insertText("\(sender.digit)")
    }

    @objc func didTapDecimalButton(_ sender: DigitButton) {
        target?.insertText(Locale.current.decimalSeparator ?? ".")
    }

    @objc func didTapDeleteButton(_ sender: DigitButton) {
        target?.deleteBackward()
    }

    @objc func didTapConvertButton(_ sender: DigitButton) {
        if let textField = target as? UITextField {
            textField.sendActions(for: .editingDidEndOnExit)
            textField.resignFirstResponder()
        }
    }

    @objc func didTapDismissButton(_ sender: DigitButton) {
        if let textField = target as? UITextField {
            textField.resignFirstResponder()
        }
    }
}
