//
//  ApiProvider.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import Foundation
import Moya

enum ApiProvider {
    case getAvailableCurrencies
    case getRates
}

extension ApiProvider: TargetType {
    public var baseURL: URL {
        return URL(string: "http://api.currencylayer.com")!
    }
    
    public var path: String {
        switch self {
        case .getAvailableCurrencies:
            return "/list"
        case .getRates:
            return "/live"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getAvailableCurrencies,
             .getRates:
            return .get
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .getAvailableCurrencies,
             .getRates:
            return .requestParameters(parameters: ["access_key": "5df5020c8cb1fa3194d5bd290700d656"], encoding: URLEncoding.queryString)
        }
    }
    
    public var headers: [String : String]? {
        return [:]
    }
}
