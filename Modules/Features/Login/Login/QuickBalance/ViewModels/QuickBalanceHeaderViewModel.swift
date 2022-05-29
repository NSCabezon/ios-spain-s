//
//  QuickBalanceHeaderViewModel.swift
//  Login
//
//  Created by Iván Estévez on 02/04/2020.
//

import Foundation
import CoreFoundationLib

struct QuickBalanceHeaderViewModel {
    let title: String
    var balance: AmountEntity?
    var updatedDate: String = ""
    
    var amountAttributedString: NSAttributedString? {
        guard let balance = balance else { return NSAttributedString(string: "") }
        let font: UIFont = .santander(family: .text, type: .bold, size: 26.0)
        let amount = MoneyDecorator(balance ?? AmountEntity.empty, font: font, decimalFontSize: 26.0)
        return amount.getFormatedCurrency()
    }
}
