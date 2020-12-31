//
//  HomeViewModel.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import Foundation
import RxCocoa
import RxSwift

struct HomeViewModel {
    
    let input: Input
    
    var onShowLoadingProgress: Observable<Bool> {
        return loadInProgress
            .asObservable()
            .distinctUntilChanged()
    }
    let onShowError = PublishSubject<Error>()
    let list: BehaviorRelay<[HomeTableViewCellDataModel]>  = BehaviorRelay(value: [])
    let selectedCurrency = PublishSubject<RealmCurrency>()
    
    private let loadInProgress = BehaviorRelay(value: false)
    let disposeBag = DisposeBag()
    
    private let dataManager = DataManager.shared
    
    init() {
        let convertText = PublishRelay<String?>()
        do {
            self.input = Input(
                convertText: convertText)
        }
        
        convertText
            .map {
                NSString(string: $0 ?? "0.0").doubleValue
            }
            .subscribe(onNext: { [self] quantity in
                self.list.accept(
                    list.value.map{ item in
                        HomeTableViewCellDataModel(
                            rate: item.rate,
                            conversion: (item.rate.exchangeRate * quantity).roundToDecimal(2))
                    }
                )
            })
            .disposed(by: disposeBag)
    
    }

    func fetchData() {
        self.loadInProgress.accept(true)
        dataManager.fetchModelForHome().subscribe(onNext: { model in
            self.selectedCurrency.onNext(model.selectedCurrency)
            self.list.accept(
                model.rates.map{HomeTableViewCellDataModel(rate: $0, conversion: 0.0)}
            )
            self.loadInProgress.accept(false)
        }, onError: { error in
            self.onShowError.onNext(error)
            self.loadInProgress.accept(false)
        }, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
    }
}


extension HomeViewModel {
    struct Input {
        let convertText: PublishRelay<String?>
    }
}
