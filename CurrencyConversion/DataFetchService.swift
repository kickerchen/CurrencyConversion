//
//  DataFetchService.swift
//  CurrencyConversion
//
//  Created by CHENCHIAN on 2021/1/25.
//

import Alamofire
import RealmSwift

// MARK: - Decodable structs

struct CurrencyResult: Codable {
    let success: Bool
    let terms: String
    let privacy: String
    let currencies: [String: String]
}

struct QuoteResult: Codable {
    let success: Bool
    let terms: String
    let privacy: String
    let source: String
    let quotes: [String: Double]
}

// MARK: - Service declaration

class CurrencyFetchService {

    static let shared: CurrencyFetchService = CurrencyFetchService()

    private let SERVICE_DOMAIN = "api.currencylayer.com"
    private let ACCESS_KEY = "13f08a1d1253bb0d246553275c507c3b"

    // MARK: - Public methods

    func fetchCurrencies() {
        Alamofire.request("https://\(SERVICE_DOMAIN)/list?access_key=\(ACCESS_KEY)")
            .responseJSON { (response) in
                if response.result.isSuccess {

                    // decode from json
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let data = response.data,
                       let result = try? decoder.decode(CurrencyResult.self, from: data) {

                        // update realm
                        let currencies = result.currencies.map { Currency(code: $0.key, country: $0.value) }
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(currencies, update: .modified)
                        }
                    }
                }
            }
    }
    
    func fetchQuotes() {
        Alamofire.request("https://\(SERVICE_DOMAIN)/live?access_key=\(ACCESS_KEY)")
            .responseJSON { (response) in
                if response.result.isSuccess {

                    // decode from json
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let data = response.data,
                       let result = try? decoder.decode(QuoteResult.self, from: data) {
                        
                        // update realm
                        let quotes = result.quotes.map { Quote(codePair: $0.key, rate: $0.value) }
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(quotes, update: .modified)
                        }
                    }
                }
            }
    }
}
