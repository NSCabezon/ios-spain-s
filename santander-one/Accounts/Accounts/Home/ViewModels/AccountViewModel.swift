//
//  AccountViewModel.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import Foundation
import CoreFoundationLib

class AccountViewModel {
    let entity: AccountEntity
    var detail: AccountDetailViewModel?
    let dependenciesResolver: DependenciesResolver
    
    init(_ entity: AccountEntity, dependenciesResolver: DependenciesResolver) {
        self.entity = entity
        self.dependenciesResolver = dependenciesResolver
    }
    
    var alias: String? {
        return entity.alias?.capitalized
    }
    
    var productNumber: String {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return entity.getIBANFormatted
        }
        return numberFormat.accountNumberFormat(entity)
    }
    
    var balanceAmountAttributedString: NSAttributedString? {
        guard let balance: AmountEntity = entity.currentBalanceAmount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .regular, size: 14)
        let amount = MoneyDecorator(balance, font: font)
        return amount.formattedNotScaledWithoutMillion
    }
    
    var availableBigAmountAttributedString: NSAttributedString? {
        guard let availableAmount: AmountEntity = entity.availableAmount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32)
        let amount = MoneyDecorator(availableAmount, font: font, decimalFontSize: 18)
        return amount.getFormattedStringWithoutMillion()
    }
    
    var availableSmallAmountAttributedString: String? {
        guard let availableAmount: AmountEntity = entity.availableAmount else { return nil}
        return availableAmount.getStringValue()
    }
    
    var withholdingAmountAttributedString: NSAttributedString? {
        return self.detail?.withholdingAmountAttributedString
    }
    
    var overdraftAmountAttributedString: NSAttributedString? {
        return self.detail?.overdraftAmountAttributedString
    }
    
    var earningsAmountAttributedString: NSAttributedString? {
        return self.detail?.earningsAmountAttributedString
    }
    
    var ownershipText: String? {
        switch entity.ownershipType {
        case .holder:
            return localized("accountHome_label_holder")
        case .attorney:
            return localized("accountHome_label_proxy")
        case .legalRepresentative:
            return localized("accountHome_label_legalResentative")
        case .additionalMember:
            return localized("accountHome_label_additionalMember")
        case .tutor:
            return localized("accountHome_label_tutor")
        case .beneficiary:
            return localized("accountHome_label_beneficiary")
        case .authorized:
            return localized("accountHome_label_authorised")
        case .unknown(let text):
            return text
        case .none:
            return nil
        }
    }
    
    var isPiggyBankAccount: Bool {
        return entity.isPiggyBankAccount
    }
    
    var isEnabledWithholdings: Bool {
        return self.dependenciesResolver.resolve(for: LocalAppConfig.self).isEnabledWithholdings
    }
    
    var ibanPapel: String {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return entity.getIBANPapel()
        }
        return numberFormat.getIBANFormatted(entity.getIban())
    }
}

extension AccountViewModel: Equatable {
    static func == (lhs: AccountViewModel, rhs: AccountViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension AccountViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(entity.getIban()?.ibanString)
    }
}

extension AccountViewModel: Shareable {
    func getShareableInfo() -> String {
        let formatter = self.dependenciesResolver.resolve(for: ShareIbanFormatterProtocol.self)
        return formatter.shareAccountNumber(entity)
    }
}
