//
//  CurrencyFetchScheduler.swift
//  CurrencyConversion
//
//  Created by CHENCHIAN on 2021/1/26.
//

import Foundation

enum PrefKey: String {
    case lastFetchDate
}

class CurrencyFetchScheduler {

    static let shared: CurrencyFetchScheduler = CurrencyFetchScheduler()
    static let fetchFrequency: TimeInterval = 2 * 60 * 60    // 2 hours

    private var timer: Timer?

    var lastFetchDate: Date? {
        get { return UserDefaults.standard.object(forKey: PrefKey.lastFetchDate.rawValue) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: PrefKey.lastFetchDate.rawValue) }
    }

    var shouldFetch: Bool {
        if let lastFetchDate = lastFetchDate,
           Date().timeIntervalSince(lastFetchDate) < CurrencyFetchScheduler.fetchFrequency {
            return false
        }
        return true
    }

    func schedule() {
        // schedule a timer if frequency is not exceeded since the previously fetched time
        if let lastFetchDate = lastFetchDate {
            let interval = CurrencyFetchScheduler.fetchFrequency - Date().timeIntervalSince(lastFetchDate)
            if interval > 0 {
                timer?.invalidate()                
                timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (_) in
                    CurrencyFetchService.shared.fetchQuotes()
                    CurrencyFetchService.shared.fetchCurrencies()
                }
            }
        }
    }
}
