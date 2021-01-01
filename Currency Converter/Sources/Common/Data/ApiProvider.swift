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

extension ApiProvider {
    
    private func getKey(key: String) -> String {
        guard let filePath = Bundle.main.path(forResource: "Credentials", ofType: "plist") else {
          fatalError("Couldn't find file Credentials.plist!")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: key) as? String else {
          fatalError("Couldn't find key \(key)!")
        }
        return value
    }
    
    private var apiURL: String {
      get {
        getKey(key: "API_URL")
      }
    }
    
    private var accessKey: String {
      get {
        getKey(key: "ACCESS_KEY")
      }
    }
}

extension ApiProvider: TargetType {
    
    public var baseURL: URL {
        return URL(string: apiURL)!
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
            return .requestParameters(parameters: ["access_key": accessKey], encoding: URLEncoding.queryString)
        }
    }
    
    public var headers: [String : String]? {
        return [:]
    }
}
