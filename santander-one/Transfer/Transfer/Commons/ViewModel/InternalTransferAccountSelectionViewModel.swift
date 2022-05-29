//
//  InternalTransferAccountSelectionViewModel.swift
//  Transfer
//
//  Created by Jose Javier Montes Romero on 28/4/21.
//
import CoreFoundationLib
import Foundation
import TransferOperatives

struct InternalTransferAccountSelectionViewModel: AccountSelectionViewModelProtocol {
    let account: AccountEntity
    private let dependenciesResolver: DependenciesResolver
    var currentBalanceAmount: NSAttributedString {
        guard let amount = self.getAmount(account: self.account) else { return NSAttributedString(string: "") }
        let font = UIFont.santander(family: .text, type: .regular, size: 22)
        let moneyDecorator = MoneyDecorator(amount, font: font, decimalFontSize: 16)
        return moneyDecorator.getFormatedCurrency() ?? NSAttributedString(string: "")
    }

    init(account: AccountEntity, dependenciesResolver: DependenciesResolver) {
        self.account = account
        self.dependenciesResolver = dependenciesResolver
    }
    
    var iban: String {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return self.account.getIBANShort
        }
        return numberFormat.accountNumberFormat(self.account)
    }
}

private extension InternalTransferAccountSelectionViewModel {
    private func getAmount(account: AccountEntity) -> AmountEntity? {
        if self.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) != nil {
            return account.availableAmount
        } else {
            return account.currentBalanceAmount
        }
    }
}
