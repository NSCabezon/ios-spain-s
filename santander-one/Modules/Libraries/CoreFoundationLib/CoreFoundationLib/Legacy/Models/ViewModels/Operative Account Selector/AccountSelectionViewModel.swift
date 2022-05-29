//
//  AccountSelectionViewModel.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 20/05/2020.
//

public protocol AccountSelectionViewModelProtocol {
    var account: AccountEntity { get }
    var alias: String { get }
    var iban: String { get }
    var currentBalanceAmount: NSAttributedString { get }
}

extension AccountSelectionViewModelProtocol {
    public var alias: String {
        return self.account.alias ?? ""
    }
    
    public var iban: String {
        return self.account.getIBANShort
    }
}
