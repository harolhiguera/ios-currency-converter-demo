//
//  Double+extension.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/30.
//

import Foundation

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
