//
//  AccountDetailDataViewModel.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 10/02/2021.
//

import CoreFoundationLib

public final class AccountDetailDataViewModel {
    let accountEntity: AccountEntity
    let accountDetailEntity: AccountDetailEntity?
    public let holder: String
    let dependenciesResolver: DependenciesResolver
    
    public init(accountEntity: AccountEntity, accountDetailEntity: AccountDetailEntity?, holder: String, dependenciesResolver: DependenciesResolver) {
        self.accountEntity = accountEntity
        self.accountDetailEntity = accountDetailEntity
        self.holder = holder
        self.dependenciesResolver = dependenciesResolver
    }
    
    public var accountName: String {
        return self.accountEntity.alias?.capitalized ?? ""
    }
    
    public var iban: String {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return accountEntity.getIBANFormatted
        }
        return numberFormat.getIBANFormatted(accountEntity.getIban())
    }
    
    public var productNumber: String? {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return accountEntity.getIBANFormatted
        }
        return numberFormat.accountNumberFormat(accountEntity)
    }
    
    public var hold: String? {
        return self.accountDetailEntity?.withholdingAmount?.getStringValue().uppercased()
    }
    
    public var mainItem: Bool? {
        return self.accountDetailEntity?.dto.mainItem
    }
    
    public var authorizedBalance: String? {
        return self.accountDetailEntity?.authorizedBalance?.getStringValue().camelCasedString
    }
    
    public var mainBalance: String? {
        return self.accountDetailEntity?.mainBalance?.getStringValue().camelCasedString
    }
    
    public var description: String? {
        return self.accountDetailEntity?.description
    }
    
    public var accountId: String? {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return self.accountDetailEntity?.accountId
        }
        return numberFormat.accountNumberFormat(self.accountDetailEntity)
    }
    
    public var bicCode: String? {
        return self.accountDetailEntity?.bicCode
    }
    
    public var interestRate: String? {
        return self.accountDetailEntity?.interestRate
    }
    
    public var currentbalance: String? {
        return self.accountDetailEntity?.currentBalance?.getStringValue().uppercased()
    }
    
    public var overdraft: String? {
        return self.accountDetailEntity?.overdraft?.getStringValue().uppercased()
    }
    
    var availableBigAmountAttributedString: NSAttributedString? {
        guard let availableAmount: AmountEntity = accountEntity.availableAmount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32)
        let amount = MoneyDecorator(availableAmount, font: font, decimalFontSize: 18)
        return self.accountDetailModifier?.isEnabledMillionFormat == true ? amount.getFormatedCurrency() : amount.getFormattedStringWithoutMillion()
    }
    
    private lazy var accountDetailModifier: AccountDetailModifierProtocol? = {
        self.dependenciesResolver.resolve(forOptionalType: AccountDetailModifierProtocol.self)
    }()
    
    private var isEnabledEditAlias: Bool {
        guard let isEnabledEditAlias = accountDetailModifier?.isEnabledEditAlias else {
            return false
        }
        return isEnabledEditAlias
    }
    
    private var isEnabledAccountHolder: Bool {
        guard let isEnabledAccountHolder = accountDetailModifier?.isEnabledAccountHolder else {
            return true
        }
        return isEnabledAccountHolder
    }
    
    var products: [AccountDetailProduct] {
        
        if let modifier = self.accountDetailModifier, let customBuilder = modifier.customAccountDetailBuilder(data: self, isEnabledEditAlias: self.isEnabledEditAlias) {
            return customBuilder
        } else {
            let builder = AccountDetailBuilder()
                .addIban(iban: self.iban)
                .addAccountName(accountName: self.accountName, isEnabledEditAlias: self.isEnabledEditAlias, maxAliasLength: nil, regExValidatorString: nil)
                .addMainBalance(mainBalance: self.mainBalance)
                .addAuthorizedBalance(authorizedBalance: self.authorizedBalance)
                .addHolder(holder: self.holder, isEnabledAccountHolder: self.isEnabledAccountHolder)
                .addDescription(description: self.description)
                .addAccountId(accountId: self.accountId)
                .addBicCode(bicCode: self.bicCode)
            return builder.build()
        }
    }
}

extension AccountDetailDataViewModel: Shareable {
    public func getShareableInfo() -> String {
        let formatter = self.dependenciesResolver.resolve(for: ShareIbanFormatterProtocol.self)
        return formatter.ibanPapel(accountEntity.getIban())
    }
}
