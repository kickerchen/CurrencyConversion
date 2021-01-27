//
//  CurrencyQuoteCell.swift
//  CurrencyConversion
//
//  Created by CHENCHIAN on 2021/1/24.
//

import UIKit

class CurrencyQuoteCell: UICollectionViewCell {

    static let cellIdentifier: String = "CurrencyQuoteCell"
    static let codePairFontSize: CGFloat = 20
    static let rateFontSize: CGFloat = 16

    private lazy var codePairLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .boldSystemFont(ofSize: CurrencyQuoteCell.codePairFontSize)
        label.textAlignment = .center
        return label
    }()

    private lazy var rateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: CurrencyQuoteCell.rateFontSize)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        // clear content
    }

    // MARK: - UI configurations
    
    private func layoutUI() {

        backgroundColor = .blue
        layer.cornerRadius = 8
        
        addSubview(codePairLabel)
        codePairLabel.translatesAutoresizingMaskIntoConstraints = false
        codePairLabel.topAnchor.constraint(equalTo: topAnchor, constant: 35).isActive = true
        codePairLabel.heightAnchor.constraint(equalToConstant: CurrencyQuoteCell.codePairFontSize).isActive = true
        codePairLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        codePairLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true

        addSubview(rateLabel)
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        rateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35).isActive = true
        rateLabel.heightAnchor.constraint(equalToConstant: CurrencyQuoteCell.rateFontSize).isActive = true
        rateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        rateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
    }
    
    // MARK: - Cell setting method

    func setupCell(withQuote quote: Quote) {        
        let formatter = NumberFormatter()
        formatter.maximumSignificantDigits = 9
        rateLabel.text = formatter.string(from: NSNumber(value: quote.rate))
        codePairLabel.text = "\(quote.codePair)"
    }
}
