//
//  AccountDetailViewModel.swift
//  Account
//
//  Created by Juan Carlos López Robles on 11/8/19.
//

import Foundation
import CoreFoundationLib

class AccountDetailViewModel {
    let entity: AccountDetailEntity
    let allowWithholdings: Bool
    let arrowWithholdVisible: Bool?
    let allowOverdraft: Bool?
    
    init(_ entity: AccountDetailEntity,
         allowWithholdings: Bool,
         arrowWithholdVisible: Bool? = nil,
         allowOverdraft: Bool? = nil) {
        self.entity = entity
        self.allowWithholdings = allowWithholdings
        self.arrowWithholdVisible = arrowWithholdVisible
        self.allowOverdraft = allowOverdraft
    }
    
    var withholdingAmountAttributedString: NSAttributedString? {
        if allowWithholdings {
            let font: UIFont = UIFont.santander(family: .text, type: .regular, size: 14)
            guard let withholdingAmount: AmountEntity = entity.withholdingAmount else {
                return MoneyDecorator(AmountEntity.empty, font: font).getCurrencyWithoutFormat() ?? NSAttributedString()
            }
            let amount = MoneyDecorator(withholdingAmount, font: font)
            return amount.formattedNotScaledWithoutMillion
        } else {
            return nil
        }
    }
    
    var overdraftAmountAttributedString: NSAttributedString? {
        if allowOverdraft == true {
            let font: UIFont = .santander(family: .text, type: .regular, size: 14)
            guard let overdraftAmount: AmountEntity = entity.overdraft else {
                return MoneyDecorator(AmountEntity.empty, font: font).getCurrencyWithoutFormat() ?? NSAttributedString()
            }
            let amount = MoneyDecorator(overdraftAmount, font: font)
            return amount.formattedNotScaledWithoutMillion
        } else {
            return nil
        }
    }
    
    var earningsAmountAttributedString: NSAttributedString? {
        let font: UIFont = .santander(family: .text, type: .regular, size: 14)
        guard let earningsAmount: AmountEntity = entity.earningsAmount else {
            return nil
        }
        let amount = MoneyDecorator(earningsAmount, font: font)
        return amount.formattedNotScaledWithoutMillion
    }
}
