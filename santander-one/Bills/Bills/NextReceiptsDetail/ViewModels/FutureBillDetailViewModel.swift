//
//  FutureBillDetailViewModel.swift
//  Bills
//
//  Created by alvola on 04/06/2020.
//

import CoreFoundationLib

final class FutureBillDetailViewModel: FutureBillViewModel {
    override var accountNumber: String {
        return account.alias ?? ""
    }
    
    override var amount: NSAttributedString? {
        guard let amount = self.amountEntity else { return nil }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32.0)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 18.0)
        return decorator.formatAsMillions()
    }
}
