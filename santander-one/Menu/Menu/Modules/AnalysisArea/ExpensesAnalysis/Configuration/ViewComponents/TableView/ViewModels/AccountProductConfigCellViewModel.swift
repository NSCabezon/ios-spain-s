//
//  AccountProductConfigCellViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 1/7/21.
//

import Foundation
import CoreFoundationLib

struct AccountAnalysisInfo {

    let alias: String
    let iban: IBANEntity
    let amount: AmountEntity
}

extension AccountAnalysisInfo: Equatable {
    static func == (lhs: AccountAnalysisInfo, rhs: AccountAnalysisInfo) -> Bool {
        lhs.alias == rhs.alias && lhs.iban == rhs.iban && lhs.amount == rhs.amount
    }
}

struct AccountProductConfigCellViewModel {
    private let account: AccountAnalysisInfo
    private let baseUrl: String?
    var isSelected: Bool
    let isLastCell: Bool
    
    init(account: AccountAnalysisInfo, baseUrl: String?, isSelected: Bool, isLastCell: Bool) {
        self.account = account
        self.baseUrl = baseUrl
        self.isSelected = isSelected
        self.isLastCell = isLastCell
    }
    
    mutating func setIsCellSelected(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    var name: String {
        return self.account.alias
    }
    
    var iban: String {
        return self.account.iban.ibanShort(asterisksCount: 1)
    }
    
    var amount: NSAttributedString? {
        let amount = self.account.amount
        let font = UIFont.santander(family: .text, type: .regular, size: 18)
        let moneyDecorator = MoneyDecorator(amount, font: font, decimalFontSize: 14)
        return moneyDecorator.getFormatedCurrency()
    }
    
    var bankIconUrl: String? {
        guard let entityCode = self.account.iban.ibanElec.substring(4, 8) else { return nil }
        let contryCode = self.account.iban.countryCode
        guard let baseUrl = self.baseUrl else { return nil }
        return String(format: "%@%@/%@_%@%@", baseUrl,
                      GenericConstants.relativeURl,
                      contryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
}

extension AccountProductConfigCellViewModel: Equatable {
    static func == (lhs: AccountProductConfigCellViewModel, rhs: AccountProductConfigCellViewModel) -> Bool {
        return lhs.account == rhs.account && lhs.isSelected == rhs.isSelected
    }
}
