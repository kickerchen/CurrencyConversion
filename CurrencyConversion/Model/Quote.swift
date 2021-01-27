//
//  Quote.swift
//  CurrencyConversion
//
//  Created by CHENCHIAN on 2021/1/22.
//

import RealmSwift

class Quote: Object {
    @objc dynamic private(set) var codePair = ""  // ex: USDAUD
    @objc dynamic var rate = 0.0                  // ex: 1.278342

    convenience init(codePair: String, rate: Double) {
        self.init()

        self.codePair = codePair
        self.rate = rate
    }

    // PrimaryKey
    override class func primaryKey() -> String? {
        return "codePair"
    }
}
