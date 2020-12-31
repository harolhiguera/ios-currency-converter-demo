//
//  HomeDataModel.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/30.
//

import Foundation

struct HomeTableViewCellDataModel {
    let rate: RealmRate
    let conversion: Double
}

struct HomeDataModel {
    let rates: [RealmRate]
    let selectedCurrency: RealmCurrency
}
