//
//  AccountDetailBuilder.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 13/4/21.
//

import CoreFoundationLib

public final class AccountDetailBuilder {
    public var values: [AccountDetailProduct] = []
    
    public init() {}
    
    public func addIban(iban: String) -> Self {
        let iban = AccountDetailProduct(title: localized("productDetail_label_iban"), value: iban, type: .icon, tooltipText: nil, titleAccessibilityID: AccessibilityAccountDetail.productDetailLabelIban, valueAccessibilityID: AccessibilityAccountDetail.productDetailValueIban)
        values.append(iban)
        return self
    }
    
    public func addAccountName(accountName: String, isEnabledEditAlias: Bool, maxAliasLength: Int?, regExValidatorString: CharacterSet?) -> Self {
        var accountNameDetail: AccountDetailProduct
        if isEnabledEditAlias {
            accountNameDetail = AccountDetailProduct(title: localized("productDetail_label_alias"), value: accountName, type: .editable, tooltipText: nil, maxAliasLength: maxAliasLength, regExValidatorString: regExValidatorString, titleAccessibilityID: AccessibilityAccountDetail.productDetailLabelAlias, valueAccessibilityID: AccessibilityAccountDetail.productDetailValueAlias)
        } else {
            accountNameDetail = AccountDetailProduct(title: localized("productDetail_label_alias"), value: accountName, type: .basic, tooltipText: nil, titleAccessibilityID: AccessibilityAccountDetail.productDetailLabelAlias, valueAccessibilityID: AccessibilityAccountDetail.productDetailValueAlias)
        }
        values.append(accountNameDetail)
        return self
    }
    
    public func addMainBalance(mainBalance: String?) -> Self {
        if let mainBalance = mainBalance, !mainBalance.isEmpty {
            let mainBalance = AccountDetailProduct(title: localized("pt_productDetail_label_bookBalance"), value: mainBalance, type: .tooltip, tooltipText: localized("pt_accountDetail_tooltip_bookBalance"), titleAccessibilityID: "pt_productDetail_label_bookBalance", valueAccessibilityID: "pt_productDetail_value_bookBalance", tooltipAccesibilityID: "pt_accountDetail_tooltip_bookBalance")
            values.append(mainBalance)
        }
        return self
    }
    
    public func addAuthorizedBalance(authorizedBalance: String?) -> Self {
        if let authorizedBalance = authorizedBalance, !authorizedBalance.isEmpty {
            let authorizedBalance = AccountDetailProduct(title: localized("pt_productDetail_label_authorizedBalance"), value: authorizedBalance, type: .tooltip, tooltipText: localized("pt_accountDetail_tooltip_authorizedBalance"), titleAccessibilityID: "pt_productDetail_label_authorizedBalance", valueAccessibilityID: "pt_productDetail_value_authorizedBalance", tooltipAccesibilityID: "pt_accountDetail_tooltip_authorizedBalance")
            values.append(authorizedBalance)
        }
        return self
    }
    
    public func addHolder(holder: String?, isEnabledAccountHolder: Bool) -> Self {
        if let holder = holder, !holder.isEmpty, isEnabledAccountHolder {
            let holder = AccountDetailProduct(title: localized("productDetail_label_holder"), value: holder.camelCasedString, type: .basic, tooltipText: nil, titleAccessibilityID: AccessibilityAccountDetail.productDetailLabelHolder, valueAccessibilityID: AccessibilityAccountDetail.productDetailValueHolder)
            values.append(holder)
        }
        return self
    }
    
    public func addDescription(description: String?) -> Self {
        if let description = description, !description.isEmpty {
            let descriptionView = AccountDetailProduct(title: localized("productDetail_label_description"), value: description, type: .basic, tooltipText: nil, titleAccessibilityID: "productDetail_label_description", valueAccessibilityID: "productDetail_value_description")
            values.append(descriptionView)
        }
        return self
    }
    
    public func addAccountId(accountId: String?) -> Self {
        if let accountId = accountId, !accountId.isEmpty {
            let accountIdView = AccountDetailProduct(title: localized("pt_productDetail_label_accountNumber"), value: accountId, type: .basic, tooltipText: nil, titleAccessibilityID: "pt_productDetail_label_accountNumber", valueAccessibilityID: "pt_productDetail_value_accountNumber")
            values.append(accountIdView)
        }
        return self
    }
    
    public func addBicCode(bicCode: String?) -> Self {
        if let bicCode = bicCode, !bicCode.isEmpty {
            let bicCodeView = AccountDetailProduct(title: localized("pt_productDetail_label_bic"), value: bicCode, type: .basic, tooltipText: nil, titleAccessibilityID: "pt_productDetail_label_bic", valueAccessibilityID: "pt_productDetail_value_bic")
            values.append(bicCodeView)
        }
        return self
    }
    
    public func addInterestRate(interestRate: String?) -> Self {
        if let interestRate = interestRate, !interestRate.isEmpty {
            let interestRateView = AccountDetailProduct(title: localized("productDetail_label_interestRate"), value: interestRate, type: .basic, tooltipText: nil, titleAccessibilityID: nil, valueAccessibilityID: nil)
            values.append(interestRateView)
        }
        return self
    }
    
    public func addCurrentBalance(currentBalance: String?) -> Self {
        if let currentBalance = currentBalance, !currentBalance.isEmpty {
            let currentBalanceView = AccountDetailProduct(title: localized("productDetail_label_realBalance"), value: currentBalance, type: .basic, tooltipText: nil, titleAccessibilityID: nil, valueAccessibilityID: nil)
            values.append(currentBalanceView)
        }
        return self
    }
    
    public func addOverdraft(overdraft: String?) -> Self {
        if let overdraft = overdraft, !overdraft.isEmpty {
            let overdraftView = AccountDetailProduct(title: localized("productDetail_label_overdraft"), value: overdraft, type: .basic, tooltipText: nil, titleAccessibilityID: nil, valueAccessibilityID: nil)
            values.append(overdraftView)
        }
        return self
    }
    
    public func build() -> [AccountDetailProduct] {
        return self.values
    }
}
