//
//  ApiModels.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import Foundation


struct GetCurrenciesResponse: Decodable {
    let success: Bool
    let terms: String?
    let privacy: String?
    let currencies: [String: String]?
    let error: ApyError?
}

struct GetRatesResponse: Decodable {
    let success: Bool
    let source: String?
    let quotes: [String: Double]?
    let error: ApyError?
}

struct ApyError: Decodable {
    let code: Int
    let info: String
}
