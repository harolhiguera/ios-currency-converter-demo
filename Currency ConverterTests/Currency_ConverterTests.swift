//
//  Currency_ConverterTests.swift
//  Currency ConverterTests
//
//  Created by Harol_Higuera on 2020/12/29.
//

import XCTest
@testable import Currency_Converter

class Currency_ConverterTests: XCTestCase {
    
    var homeViewModel: HomeViewModel!
    
    override func setUp() {
        super.setUp()
        homeViewModel = HomeViewModel(dataManager: DataManager())
    }
    
    func testGetUser() {
        homeViewModel.fetchData()
    }
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
