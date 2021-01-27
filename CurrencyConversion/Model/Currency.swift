//
//  Currency.swift
//  CurrencyConversion
//
//  Created by CHENCHIAN on 2021/1/22.
//

import RealmSwift

class Currency: Object {
    @objc dynamic private(set) var code = ""      // ex: AED
    @objc dynamic private(set) var country = ""   // ex: United Arab Emirates Dirham

    convenience init(code: String, country: String) {
        self.init()

        self.code = code
        self.country = country
    }

    // PrimaryKey
    override class func primaryKey() -> String? {
        return "code"
    }
}
