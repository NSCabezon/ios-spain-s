//
//  OneAccountsSelectedCardViewModelExtensions.swift
//  UIOneComponents
//
//  Created by David Gálvez Alonso on 01/09/2021.
//

import CoreFoundationLib
import CoreDomain

public extension OneAccountsSelectedCardViewModel {
    
    var formattedAmount: String? {
        guard let amount = self.originAmount else { return nil }
        return AmountRepresentableDecorator(amount, font: UIFont.santander(size: 10)).getFormatedWithCurrencyName()?.string
    }
}
