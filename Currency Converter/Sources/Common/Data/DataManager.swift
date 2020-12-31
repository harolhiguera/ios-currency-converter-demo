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

struct DataManager {
    var apiProvider: MoyaProvider<ApiProvider>
    let currenciesRepository: CurrenciesRepository
    let ratesRepository: RatesRepository
    let realm: Realm
    
    static let shared = DataManager()
    
    init() {
        apiProvider = MoyaProvider<ApiProvider>()
        realm = try! Realm()
        currenciesRepository = CurrenciesRepository(realm)
        ratesRepository = RatesRepository(realm)
    }
    /**
     Fetch Data for HomeViewController
     */
    func fetchModelForHome() -> Observable<HomeDataModel>{
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
        let selectedCurrencyCode = UserDefaultsUtils.selectedCurrencyCode ?? ""
        return self.getRatesFor(currencyCode: selectedCurrencyCode)
            .flatMap({ rates in
                self.currenciesRepository.getCurrency(code: selectedCurrencyCode)
                    .flatMap({ currency in
                        Observable.create { observer in
                            observer.onNext(HomeDataModel(rates: rates, selectedCurrency: currency))
                            observer.onCompleted()
                            return Disposables.create()
                        }
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
                            .flatMap({ getRatesResponse in
                                self.ratesRepository.updateRates(entry: getRatesResponse, currenciesRepository: currenciesRepository)
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

