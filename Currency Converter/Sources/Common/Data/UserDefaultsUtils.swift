//
//  UserDefaultsUtils.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import Foundation

struct UserDefaultsUtils {
    static let userDefault = UserDefaults.standard
    
    struct Key {
        static let nextUpdatedAt = "next_updated_at"
        static let selectedCurrencyCode = "selected_currency_code"
    }
}

extension UserDefaultsUtils {
    static var nextUpdatedAt: Date? {
        get {
            return userDefault.object(forKey: Key.nextUpdatedAt) as? Date
        }
        set {
            userDefault.set(newValue, forKey: Key.nextUpdatedAt)
            userDefault.synchronize()
        }
    }
    
    static var selectedCurrencyCode: String? {
        get {
            return userDefault.object(forKey: Key.selectedCurrencyCode) as? String
        }
        set {
            userDefault.set(newValue, forKey: Key.selectedCurrencyCode)
            userDefault.synchronize()
        }
    }
}
