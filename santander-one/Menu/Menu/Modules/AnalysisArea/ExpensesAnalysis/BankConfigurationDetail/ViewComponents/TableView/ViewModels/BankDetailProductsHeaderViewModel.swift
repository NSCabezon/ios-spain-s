//
//  BankDetailProductsHeaderViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 14/7/21.
//

import CoreFoundationLib

struct BankDetailProductsHeaderViewModel {
    let bankImageUrl: String
    private let totalProducts: Int
    private let date: Date
    private let timeManager: TimeManager
    
    init(timeManager: TimeManager, date: Date, totalProducts: Int, bankImageUrl: String) {
        self.timeManager = timeManager
        self.date = date
        self.totalProducts = totalProducts
        self.bankImageUrl = bankImageUrl
    }
    
    private var formattedDate: String {
        return self.timeManager.toString(date: self.date, outputFormat: .eeee_HHmm) ?? ""
    }
    
    private var placeholder: [StringPlaceholder] {
        return [StringPlaceholder(.date, self.formattedDate)]
    }
    
    var lastUpdateText: LocalizedStylableText {
        return localized("analysis_label_lastUpdate", self.placeholder)
    }
    
    private var totalPlaceholder: [StringPlaceholder] {
        return [StringPlaceholder(.number, "\(totalProducts)")]
    }
    
    var totalProductsText: LocalizedStylableText {
        return localized("analysis_label_product_other", self.totalPlaceholder)
    }
}
