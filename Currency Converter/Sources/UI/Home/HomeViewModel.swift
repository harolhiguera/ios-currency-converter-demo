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
    
    
    func fetchData() {
        self.loadInProgress.accept(true)
        dataManager.fetchModelForHome().subscribe(onNext: { model in
            self.selectedCurrency.onNext(model.selectedCurrency)
            self.setListItems(model.rates)
            self.loadInProgress.accept(false)
        }, onError: { error in
            self.onShowError.onNext(error)
            self.loadInProgress.accept(false)
        }, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
    }
    
    func setListItems(_ realmList: [RealmRate]) {
        list.accept(
            realmList.map{HomeTableViewCellDataModel(rate: $0, conversion: 0.0)}
        )
    }
    
    func updateConversions(quantity: Double) {
        list.accept(
            list.value.map{
                HomeTableViewCellDataModel(
                    rate: $0.rate,
                    conversion: ($0.rate.exchangeRate * quantity).roundToDecimal(2)
                )
            }
        )
    }
}
