//
//  CurrenciesViewModel.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import Foundation
import RxCocoa
import RxSwift

struct CurrenciesViewModel {
    
    var onShowLoadingProgress: Observable<Bool> {
        return loadInProgress
            .asObservable()
            .distinctUntilChanged()
    }
    let onShowError = PublishSubject<Error>()
    let currencies = PublishSubject<[RealmCurrency]>()
    
    private let loadInProgress = BehaviorRelay(value: false)
    let disposeBag = DisposeBag()
    
    private let dataManager = DataManager.shared
    
    
    func fetchData() {
        self.loadInProgress.accept(true)
        dataManager.fetchCurrencies().subscribe(onNext: { currencies in
            self.currencies.onNext(currencies)
            self.loadInProgress.accept(false)
        }, onError: { error in
            self.onShowError.onNext(error)
            self.loadInProgress.accept(false)
        }, onCompleted:  nil , onDisposed: nil)
        .disposed(by: disposeBag)
    }
    
    func setSelectedCurrencyCode(code: String) {
        dataManager.setSelectedCurrencyCode(code: code)
    }
}
