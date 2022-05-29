//
//  AccountDetailModifierProtocol.swift
//  Account
//
//  Created by crodrigueza on 22/7/21.
//

public protocol AccountDetailModifierProtocol {
    var isEnabledMillionFormat: Bool { get }
    var maxAliasLength: Int { get }
    var isEnabledEditAlias: Bool { get }
    var isEnabledAccountHolder: Bool { get }
    var regExValidatorString: CharacterSet { get }
    func customAccountDetailBuilder(data: AccountDetailDataViewModel, isEnabledEditAlias: Bool) -> [AccountDetailProduct]?
}

extension AccountDetailModifierProtocol {
    public var maxAliasLength: Int {
        return 20
    }
    public var regExValidatorString: CharacterSet {
        return .alias
    }
}
