//
//  DataManager.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import Foundation
import RxSwift
import Moya
import Alamofire
import RealmSwift

protocol DataManagerProtocol: class {
    func fetchModelForHome() -> Observable<HomeDataModel>
    func fetchCurrencies() -> Observable<[RealmCurrency]>
    func setSelectedCurrencyCode(code: String)
}

class DataManager: DataManagerProtocol {
    var apiProvider: MoyaProvider<ApiProvider>
    let currenciesRepository: CurrenciesRepository
    let ratesRepository: RatesRepository
    let realm: Realm
    
    init() {
        apiProvider = MoyaProvider<ApiProvider>()
        realm = try! Realm()
        currenciesRepository = CurrenciesRepository(realm)
        ratesRepository = RatesRepository(realm)
    }
    /**
     Fetch Data for HomeViewController
     */
    func fetchModelForHome() -> Observable<HomeDataModel> {
        if !self.shouldRefreshData() {
            return self.getHomeDataModelFromDisk()
        }
        return self.refreshData()
            .flatMap({ _ in
                self.getHomeDataModelFromDisk()
            })
    }
    
    /**
     Fetch Data for CurrenciesViewController
     */
    func fetchCurrencies() -> Observable<[RealmCurrency]> {
        if !self.shouldRefreshData() {
            return self.currenciesRepository.getCurrencies()
        }
        return self.refreshData()
            .flatMap({
                self.currenciesRepository.getCurrencies()
            })
    }
    
    func setSelectedCurrencyCode(code: String) {
        UserDefaultsUtils.selectedCurrencyCode = code
    }
    
    /**
     Fails if no currency selected. But it shouldn't accoring to the logic.
     */
    private func getHomeDataModelFromDisk() -> Observable<HomeDataModel> {
        return getCurrencySelectedCode()
            .flatMap({ code in
                self.getRatesFor(currencyCode: code)
                    .flatMap({ rates in
                        self.currenciesRepository.getCurrency(code: code)
                            .flatMap({ currency in
                                Observable.create { observer in
                                    observer.onNext(HomeDataModel(rates: rates, selectedCurrency: currency))
                                    observer.onCompleted()
                                    return Disposables.create()
                                }
                            })
                    })
            })
        
    }
    
    private func getRatesFor(currencyCode: String) -> Observable<[RealmRate]> {
        if !self.shouldRefreshData() {
            return self.ratesRepository.getRates(for: currencyCode)
        }
        return self.refreshData()
            .flatMap({ _ in
                self.ratesRepository.getRates(for: currencyCode)
            })
    }
    
    private func refreshData() -> Observable<Void> {
        return self.fetchCurrenciesFromServer()
            .asObservable()
            .flatMap({ getCurrenciesResponse in
                self.currenciesRepository.updateCurrencies(entry: getCurrenciesResponse)
                    .flatMap({ _ in
                        self.fetchRatesFromServer()
                            .asObservable()
                            .flatMap({ [self] getRatesResponse in
                                self.ratesRepository.updateRates(
                                    entry: getRatesResponse,
                                    currenciesRepository: self.currenciesRepository)
                                    .flatMap({ _ in
                                        self.updateNextUpdatedAt()
                                    })
                            })
                    })
            })
    }
    
    private func fetchCurrenciesFromServer() -> Single<GetCurrenciesResponse> {
        return apiProvider.rx
            .request(.getAvailableCurrencies)
            .filterSuccessfulStatusCodes()
            .map(GetCurrenciesResponse.self)
    }
    
    private func fetchRatesFromServer() -> Single<GetRatesResponse> {
        return apiProvider.rx
            .request(.getRates)
            .filterSuccessfulStatusCodes()
            .map(GetRatesResponse.self)
    }
    
    private func getCurrencySelectedCode() -> Observable<String> {
        return Observable.create { observer in
            guard let code = UserDefaultsUtils.selectedCurrencyCode else {
                let errorTemp = NSError(domain: "", code: 0, userInfo: ["NSLocalizedDescription": "Select a currency"])
                observer.onError(errorTemp as Error)
                observer.onCompleted()
                return Disposables.create()
            }
            observer.onNext(code)
            observer.onCompleted()
            return Disposables.create()
        }
        
    }
    
    private func shouldRefreshData() -> Bool {
        guard let nextUpdatedAt = UserDefaultsUtils.nextUpdatedAt else {
            return true
        }
        return Date() > nextUpdatedAt
    }
    
    /**
     Rates should be persisted locally and refreshed no more frequently than every 30 minutes (to limit bandwidth usage)
     */
    private func updateNextUpdatedAt() -> Observable<Void> {
        return Observable.create { observer in
            UserDefaultsUtils.nextUpdatedAt =
                Date().addingTimeInterval(TimeInterval(TimeInterval(30.0 * 60.0)))
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
}

