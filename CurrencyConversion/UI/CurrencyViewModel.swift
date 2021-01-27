//
//  CurrencyViewModel.swift
//  CurrencyConversion
//
//  Created by CHENCHIAN on 2021/1/22.
//

import RealmSwift
import RxSwift
import RxCocoa

protocol CurrencyVMInputs {
    func selectCurrency(with code: String)
    func convertRates(with amount: Double)
}

protocol CurrencyVMOutputs {
    var isReady: Driver<Bool> { get }
    var hasUpdate: Signal<Void> { get }
}

class CurrencyViewModel: NSObject, CurrencyVMInputs, CurrencyVMOutputs {
    var inputs: CurrencyVMInputs { return self }
    var outputs: CurrencyVMOutputs { return self }

    private let isReadyRelay = BehaviorRelay<Bool>(value: false)
    private let hasUpdateRelay = PublishRelay<Void>()
    
    private let currencyInitialObserver = ReplaySubject<Bool>.create(bufferSize: 1)
    private let quoteInitialObserver = ReplaySubject<Bool>.create(bufferSize: 1)

    private var displayQuotes: [Quote] = []
    private var selectedCode = "USD"
    private var enteredAmount = 1.0

    private(set) lazy var isReady: Driver<Bool> = isReadyRelay.asDriver()
    private(set) lazy var hasUpdate: Signal<Void> = hasUpdateRelay.asSignal()

    private let bag = DisposeBag()
    
    private var notificationTokenForCurrency: NotificationToken?
    private var notificationTokenForQuote: NotificationToken?

    // MARK: - Initializer

    override init() {
        super.init()

        // monitor db update
        addRealmObservers()

        // check db has data already
        checkDBReady()

        // fetch immediately or schedule a timer
        fetchDataIfNeeded()
    }

    // MARK: - Private methods
    
    private func addRealmObservers() {
        let realm = try! Realm()

        notificationTokenForCurrency = realm.objects(Currency.self).observe { [weak self] (changes) in
            guard let self = self else { return }

            switch (changes) {
            case .initial: break
            case .update:
                self.currencyInitialObserver.onNext(true)
                self.currencyInitialObserver.onCompleted()
            case .error: break
            }
        }

        notificationTokenForQuote = realm.objects(Quote.self).observe { [weak self] (changes) in
            guard let self = self else { return }

            switch (changes) {
            case .initial: break
            case .update(let quoteResults, _, let insertions, _):
                if !insertions.isEmpty {
                    insertions.forEach { self.displayQuotes.append(quoteResults[$0]) }
                }
                self.quoteInitialObserver.onNext(true)
                self.quoteInitialObserver.onCompleted()
                self.hasUpdateRelay.accept(())
            case .error: break
            }
        }
        
        Observable
            .combineLatest(currencyInitialObserver, quoteInitialObserver)
            .take(1)
            .asSingle()
            .subscribe(onSuccess: { _ in
                self.isReadyRelay.accept(true)
            }).disposed(by: bag)
    }

    private func checkDBReady() {
        let realm = try! Realm()
        let currenciesFromDB = realm.objects(Currency.self)
        let quotesFromDB = realm.objects(Quote.self)

        if !currenciesFromDB.isEmpty && !quotesFromDB.isEmpty {
            displayQuotes = quotesFromDB.map { $0 }.sorted { $0.codePair < $1.codePair }
            isReadyRelay.accept(true)
        }
    }

    private func fetchDataIfNeeded() {
        let scheduler = CurrencyFetchScheduler.shared

        if scheduler.shouldFetch {
            CurrencyFetchService.shared.fetchCurrencies()
            CurrencyFetchService.shared.fetchQuotes()
        } else {
            scheduler.schedule()
        }
    }

    private func updateQuotes() {
        let realm = try! Realm()
        let quotes = realm.objects(Quote.self)
        let quotient = 1.0 / quotes.filter { $0.codePair.suffix(3) == self.selectedCode }.first!.rate

        displayQuotes = quotes.map {
            Quote(codePair: self.selectedCode + $0.codePair.suffix(3), rate: self.enteredAmount * quotient * $0.rate)
        }.sorted { $0.codePair < $1.codePair }

        hasUpdateRelay.accept(())
    }

    // MARK: - Public methods

    func selectCurrency(with code: String) {
        selectedCode = code
        updateQuotes()
    }

    func convertRates(with amount: Double) {
        enteredAmount = amount
        updateQuotes()
    }
}

// MARK: - UICollectionViewDataSource

extension CurrencyViewModel: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayQuotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let quoteCell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyQuoteCell.cellIdentifier, for: indexPath) as? CurrencyQuoteCell, indexPath.row < displayQuotes.count {
            let quote = displayQuotes[indexPath.row]
            quoteCell.setupCell(withQuote: quote)
            return quoteCell
        }
        return UICollectionViewCell()
    }
}
