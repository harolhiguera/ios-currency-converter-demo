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
    let output: Output
    
    let disposeBag = DisposeBag()
    let dataManager: DataManagerProtocol
    
    init(dataManager: DataManagerProtocol = DataManager()) {
        self.dataManager = dataManager
        
        let convertText = PublishRelay<String?>()
        let fetchData = PublishRelay<Void>()
        
        self.input = Input(
            convertText: convertText,
            fetchData: fetchData)
        
        let onShowLoadingProgress: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        let onShowError = PublishSubject<String>()
        let list: BehaviorRelay<[HomeTableViewCellDataModel]>  = BehaviorRelay(value: [])
        let selectedCurrency = PublishSubject<RealmCurrency>()
        
        self.output = Output(
            onShowLoadingProgress: onShowLoadingProgress,
            onShowError: onShowError,
            list: list,
            selectedCurrency: selectedCurrency)
        
        convertText
            .map {
                NSString(string: $0 ?? "0.0").doubleValue
            }
            .subscribe(onNext: { quantity in
                list.accept(
                    list.value.map{ item in
                        HomeTableViewCellDataModel(
                            rate: item.rate,
                            conversion: (item.rate.exchangeRate * quantity).roundToDecimal(2))
                    }
                )
            })
            .disposed(by: disposeBag)
        
        fetchData
            .subscribe(onNext: { [self] in
                onShowLoadingProgress.accept(true)
                self.dataManager.fetchModelForHome().subscribe(onNext: { model in
                    selectedCurrency.onNext(model.selectedCurrency)
                    list.accept(
                        model.rates.map{HomeTableViewCellDataModel(rate: $0, conversion: 0.0)}
                    )
                    onShowLoadingProgress.accept(false)
                }, onError: { error in
                    onShowError.onNext(error.localizedDescription)
                    onShowLoadingProgress.accept(false)
                }, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
                
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewModel {
    struct Input {
        let convertText: PublishRelay<String?>
        let fetchData: PublishRelay<Void>
    }
    struct Output {
        let onShowLoadingProgress: BehaviorRelay<Bool>
        let onShowError: PublishSubject<String>
        let list: BehaviorRelay<[HomeTableViewCellDataModel]>
        let selectedCurrency: PublishSubject<RealmCurrency>
    }
}
