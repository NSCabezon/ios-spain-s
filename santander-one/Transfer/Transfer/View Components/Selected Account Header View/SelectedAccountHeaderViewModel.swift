//
//  SelectedAccountHeaderViewModel.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 07/01/2020.
//

import CoreFoundationLib
import TransferOperatives

public struct SelectedAccountHeaderViewModel {
    
    private let dependenciesResolver: DependenciesResolver
    
    private let account: AccountEntity
    let action: () -> Void
    
    public init(account: AccountEntity, action: @escaping () -> Void, dependenciesResolver: DependenciesResolver) {
        self.account = account
        self.action = action
        self.dependenciesResolver = dependenciesResolver
    }
    
    var alias: String {
        return account.alias ?? ""
    }
    
    var currentBalanceAmount: String {
        guard let amount = getAmount(account: self.account) else { return "" }
        return amount.getStringValue()
    }
}

private extension SelectedAccountHeaderViewModel {
    private func getAmount(account: AccountEntity) -> AmountEntity? {
        if self.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) != nil {
            return account.availableAmount
        } else {
            return account.currentBalanceAmount
        }
    }
}
