//
//  TotalSavingsViewModel.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 01/04/2020.
//

import CoreFoundationLib

struct TotalSavingsViewModel {
    private let months: [String]
    private let amount: Decimal
    
    public init (months: [String], amount: Decimal) {
        self.months = months
        self.amount = amount
    }
    
    public func localizedTitle() -> LocalizedStylableText? {
        guard let firstMonth = months.first, let lastMonth = months.last else {
            return nil
        }
        let amountWithCurrencySymbol = amount.toStringWithCurrency()
        let localizedText = localized("analysis_label_lastMonthSavings", [StringPlaceholder(.value, firstMonth), StringPlaceholder(.value, lastMonth), StringPlaceholder(.value, amountWithCurrencySymbol)])
        return localizedText
    }
}
