//
//  CurrenciesRepository.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import Foundation
import RealmSwift
import RxSwift

class RealmCurrency: Object {
    @objc dynamic var currencyCode = ""
    @objc dynamic var currencyName = ""
}

struct CurrenciesRepository {
    
    let realm : Realm
    
    init(_ realm: Realm) {
        self.realm = realm
    }
    
    // Get
    func getCurrencies() -> Observable<[RealmCurrency]> {
        return Observable.create { observer in
            var result = [RealmCurrency]()
            let currencies = self.realm.objects(RealmCurrency.self).sorted(byKeyPath: "currencyCode")
            currencies.forEach {
                result.append($0)
            }
            observer.onNext(result)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func getCurrency(code: String) -> Observable<RealmCurrency> {
        return Observable.create { observer in
            guard let currency = self.realm.objects(RealmCurrency.self).filter("currencyCode = '\(code)'").first else {
                fatalError("To Do, handle this error. It shouldn't happen.")
            }
            observer.onNext(currency)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    // Update
    func updateCurrencies(entry: GetCurrenciesResponse) -> Observable<Void> {
        return deleteCurrencies().flatMap({ _ in
            Observable.create { observer in
                var list = [RealmCurrency]()
                guard let currencies = entry.currencies else {
                    observer.onNext(())
                    observer.onCompleted()
                    return Disposables.create()
                }
                for (code, name) in currencies {
                    let newItem = RealmCurrency()
                    newItem.currencyCode = code
                    newItem.currencyName = name
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
    }
    
    // Delete
    func deleteCurrencies() -> Observable<Void> {
        return Observable.create { observer in
            let currencies = self.realm.objects(RealmCurrency.self)
            try! self.realm.write {
                realm.delete(currencies)
            }
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
}
