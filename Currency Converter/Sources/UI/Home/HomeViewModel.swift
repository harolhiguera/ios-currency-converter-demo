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
            self.input = Input(convertText: convertText)
        }
        convertText
            .map {
                guard let char = $0 else {
                    return 0.0
                }
                return NSString(string: char).doubleValue
            }
            .subscribe(onNext: { [self] in
                self.updateConversions(quantity: $0)
            })
            .disposed(by: disposeBag)
    }

    
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


extension HomeViewModel {
    struct Input {
        let convertText: PublishRelay<String?>
    }
}
