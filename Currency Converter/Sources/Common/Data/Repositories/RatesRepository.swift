//
//  RatesRepository.swift
//  Rate Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import Foundation
import RealmSwift
import RxSwift

class RealmRate: Object {
    @objc dynamic var baseCurrencyCode = ""
    @objc dynamic var currencyCode = ""
    @objc dynamic var currencyName = ""
    @objc dynamic var exchangeRate = 0.0
}

struct RatesRepository {
    let initialCode = "USD"
    let realm : Realm
    
    init(_ realm: Realm) {
        self.realm = realm
    }
    
    // Get
    func getRates(for currencyCode: String) -> Observable<[RealmRate]> {
        return Observable.create { observer in
            var result = [RealmRate]()
            let rates = getOrBuildRates(for: currencyCode)
            for item in rates {
                result.append(item)
            }
            observer.onNext(result)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    private func getOrBuildRates(for currencyCode: String) -> Results<RealmRate> {
        var rates: Results<RealmRate>
        rates = self.realm.objects(RealmRate.self).filter("baseCurrencyCode = '\(currencyCode)'").sorted(byKeyPath: "currencyCode")
        if (!rates.isEmpty) {
            return rates
        }
        
        let usdRates = self.realm.objects(RealmRate.self).filter("baseCurrencyCode = '\(initialCode)'")
        if usdRates.isEmpty {
            fatalError("To Do, handle this error. It shouldn't happen.")
        }
        guard let usdNewCodeRate = self.realm.objects(RealmRate.self).filter("baseCurrencyCode = '\(initialCode)' AND currencyCode = '\(currencyCode)'").first else {
            fatalError("To Do, handle this error. It shouldn't happen.")
        }
        var list = [RealmRate]()
        for item in usdRates {
            let newItem = RealmRate()
            newItem.baseCurrencyCode = currencyCode
            newItem.currencyCode = item.currencyCode
            newItem.currencyName = item.currencyName
            newItem.exchangeRate = (item.exchangeRate / usdNewCodeRate.exchangeRate)
            list.append(newItem)
        }
        try! self.realm.write {
            realm.add(list)
        }
        return self.realm.objects(RealmRate.self).filter("baseCurrencyCode = '\(currencyCode)'").sorted(byKeyPath: "currencyCode")
    }
    
    // Update
    func updateRates(entry: GetRatesResponse, currenciesRepository: CurrenciesRepository) -> Observable<Void> {
        return currenciesRepository.getCurrencies()
            .flatMap({ currencies in
                deleteRates()
                    .flatMap({ _ in
                        Observable.create { observer in
                            var list = [RealmRate]()
                            guard let rates = entry.quotes else {
                                observer.onNext(())
                                observer.onCompleted()
                                return Disposables.create()
                            }
                            for (code, rate) in rates {
                                let newItem = RealmRate()
                                newItem.baseCurrencyCode = String(code.prefix(3))
                                newItem.currencyCode = String(code.suffix(3))
                                if let currency = currencies.filter({$0.currencyCode == newItem.currencyCode}).first {
                                    newItem.currencyName = currency.currencyName
                                }
                                newItem.exchangeRate = rate
                                list.append(newItem)
                            }
                            try! self.realm.write {
                                realm.add(list)
                            }
                            observer.onNext(())
                            observer.onCompleted()
                            return Disposables.create()
                        }
                    })
            })
    }
    
    // Delete
    func deleteRates() -> Observable<Void> {
        return Observable.create { observer in
            let rates = self.realm.objects(RealmRate.self)
            try! self.realm.write {
                realm.delete(rates)
            }
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
}
