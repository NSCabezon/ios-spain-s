//
//  QuickBalanceMovementViewModel.swift
//  Login
//
//  Created by Iván Estévez on 03/04/2020.
//

import Foundation
import CoreFoundationLib

struct QuickBalanceMovementViewModel {
    let date: String
    let movement: String
    let amount: AmountEntity 
    let account: String
    
    var amountAttributedString: NSAttributedString? {
        let font: UIFont = .santander(family: .text, type: .bold, size: 13.0)
        let amountResult = MoneyDecorator(amount, font: font, decimalFontSize: 13.0)
        return amountResult.getFormatedCurrency()
    }
}
