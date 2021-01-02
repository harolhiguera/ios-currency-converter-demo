//
//  HomeViewModelTests.swift
//  Currency ConverterTests
//
//  Created by Harol_Higuera on 2021/01/01.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import Currency_Converter

class HomeViewModelTests: XCTestCase {
    
    var homeViewModel: HomeViewModel!
    var disposeBag: DisposeBag!
    var testScheduler: TestScheduler!
    fileprivate var dataManager: MockDataManager!
    
    override func setUp() {
        super.setUp()
        dataManager = MockDataManager()
        homeViewModel = HomeViewModel(dataManager: dataManager)
        disposeBag = DisposeBag()
        testScheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        self.homeViewModel = nil
        self.dataManager = nil
        self.testScheduler = nil
        super.tearDown()
    }
    
    func testNoCurrencyUnselected() throws {
        
        let errorMessage = testScheduler.createObserver(String.self)
        let selectedCurrency = testScheduler.createObserver(RealmCurrency.self)
        let cellsList = testScheduler.createObserver([HomeTableViewCellDataModel].self)
        
        homeViewModel.output.onShowError
            .bind(to: errorMessage)
            .disposed(by: disposeBag)
        
        homeViewModel.output.selectedCurrency
            .bind(to: selectedCurrency)
            .disposed(by: disposeBag)
        
        homeViewModel.output.list
            .bind(to: cellsList)
            .disposed(by: disposeBag)
        
        testScheduler.createColdObservable([.next(5, ())])
            .observeOn(MainScheduler.instance)
            .bind(to: homeViewModel.input.fetchData)
            .disposed(by: disposeBag)
        testScheduler.start()
        
        XCTAssertEqual(errorMessage.events, [.next(5, "Select a currency")])
        XCTAssertEqual(selectedCurrency.events.count, 0)
        XCTAssertEqual(cellsList.events, [.next(0, [])])
    }
    
    func testNoCurrencySelected() throws {
        
        let errorMessage = testScheduler.createObserver(String.self)
        let selectedCurrency = testScheduler.createObserver(RealmCurrency.self)
        let cellsList = testScheduler.createObserver([HomeTableViewCellDataModel].self)
        
        dataManager.setSelectedCurrencyCode(code: "some_code")
        
        homeViewModel.output.onShowError
            .bind(to: errorMessage)
            .disposed(by: disposeBag)
        
        homeViewModel.output.selectedCurrency
            .bind(to: selectedCurrency)
            .disposed(by: disposeBag)
        
        homeViewModel.output.list
            .bind(to: cellsList)
            .disposed(by: disposeBag)
        
        testScheduler.createColdObservable([.next(5, ())])
            .observeOn(MainScheduler.instance)
            .bind(to: homeViewModel.input.fetchData)
            .disposed(by: disposeBag)
        testScheduler.start()
        
        // Error. There would be any error
        XCTAssertEqual(errorMessage.events.count, 0)
        
        // Selected Currency
        let retrievedCode: String = selectedCurrency.events.first?.value.element?.currencyCode ?? ""
        let expectedCode = MockData.testCurrency.currencyCode
        XCTAssertEqual(retrievedCode, expectedCode)
        
        // Cell list count
        let retrievedItemsCount = cellsList.events.count - 1 // Minus List initialization event
        let expectedItemsCount = 1
        XCTAssertEqual(retrievedItemsCount, expectedItemsCount)
        
        // Cell list content
        let retrievedConversion: String = cellsList.events[1].value.element?.first?.rate.currencyName ?? ""
        let expectedConversion = MockData.testRates.map {
            HomeTableViewCellDataModel(rate: $0, conversion: 0.0)
        }.first!.rate.currencyName
        XCTAssertEqual(retrievedConversion, expectedConversion)
    }
}


fileprivate class MockData {
    static var testRates: [RealmRate] {
        get {
            let rate = RealmRate()
            rate.baseCurrencyCode = "USD"
            rate.currencyName = "Japanese Yen"
            rate.currencyCode = "JPY"
            rate.exchangeRate = 103.240385
            return [rate]
        }
    }
    static var testCurrency: RealmCurrency {
        get {
            let currency = RealmCurrency()
            currency.currencyCode = "JPY"
            currency.currencyName = "Japanese Yen"
            return currency
        }
    }
}

fileprivate class MockDataManager: DataManagerProtocol {
    
    var testModel: HomeDataModel {
        get {
            return HomeDataModel(rates: MockData.testRates, selectedCurrency: MockData.testCurrency)
        }
    }
    
    var selectedCurrencyCode: String?
    var model: HomeDataModel?
    
    
    func setSelectedCurrencyCode(code: String) {
        selectedCurrencyCode = code
        model = testModel
    }
    
    func fetchModelForHome() -> Observable<HomeDataModel> {
        if selectedCurrencyCode != nil, let model = model {
            return Observable.just(model)
        } else {
            let errorTemp = NSError(domain: "", code: 0, userInfo: ["NSLocalizedDescription": "Select a currency"])
            return Observable.error(errorTemp as Error)
        }
    }
    
    func fetchCurrencies() -> Observable<[RealmCurrency]> {
        return Observable.just([RealmCurrency()])
    }
}
