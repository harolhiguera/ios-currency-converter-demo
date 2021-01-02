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
    
    let input: Input
    let output: Output
    
    let disposeBag = DisposeBag()
    let dataManager: DataManagerProtocol
    
    init(dataManager: DataManagerProtocol = DataManager()) {
        self.dataManager = dataManager
        
        let fetchData = PublishRelay<Void>()
        let setSelectedCurrencyCode = PublishRelay<String>()
        
        self.input = Input(
            fetchData: fetchData,
            setSelectedCurrencyCode: setSelectedCurrencyCode)
        
        let onShowLoadingProgress: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        let onShowError = PublishSubject<String>()
        let currencies = PublishSubject<[RealmCurrency]>()
        
        self.output = Output(
            onShowLoadingProgress: onShowLoadingProgress,
            onShowError: onShowError,
            currencies: currencies)
        
        fetchData
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [self] in
                onShowLoadingProgress.accept(true)
                self.dataManager.fetchCurrencies().subscribe(onNext: { result in
                    currencies.onNext(result)
                    onShowLoadingProgress.accept(false)
                }, onError: { error in
                    onShowError.onNext(error.localizedDescription)
                    onShowLoadingProgress.accept(false)
                }, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        setSelectedCurrencyCode
            .subscribe(onNext: { [self] code in
                self.dataManager.setSelectedCurrencyCode(code: code)
            })
            .disposed(by: disposeBag)
    }
}

extension CurrenciesViewModel {
    struct Input {
        let fetchData: PublishRelay<Void>
        let setSelectedCurrencyCode: PublishRelay<String>
    }
    struct Output {
        let onShowLoadingProgress: BehaviorRelay<Bool>
        let onShowError: PublishSubject<String>
        let currencies: PublishSubject<[RealmCurrency]>
    }
}
