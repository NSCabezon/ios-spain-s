import Foundation
import SANLegacyLibrary
import CoreDomain

// MARK: - AccountEasyPayChecker
public enum AccountEasyPayFundableType {
    case high
    case low
    case notAllowed
}

public struct AccountEasyPay {
    let accountEasyPayMinAmount: Decimal
    let accountEasyPayLowAmountLimit: Decimal
    let campaignsEasyPay: [AccountEasyPayRepresentable]
    var grantedHighAmount: AmountEntity? {
        guard let grantedAmount = campaignsEasyPay.first?.grantedAmountRepresentable else { return nil }
        return AmountEntity(grantedAmount)
    }
    var grantedLowAmount: AmountEntity? {
        guard let grantedAmount = campaignsEasyPay.first(where: { $0.campaignCode.hasPrefix("E26") })?.grantedAmountRepresentable else { return nil }
        return AmountEntity(grantedAmount)
    }
    
    public init(accountEasyPayMinAmount: Decimal, accountEasyPayLowAmountLimit: Decimal, campaignsEasyPay: [AccountEasyPayRepresentable]) {
        self.accountEasyPayMinAmount = accountEasyPayMinAmount
        self.accountEasyPayLowAmountLimit = accountEasyPayLowAmountLimit
        self.campaignsEasyPay = campaignsEasyPay
    }
}

public protocol AccountEasyPayChecker {
    func easyPayFundableType(for amount: AmountEntity, transaction: EasyPayTransaction, accountEasyPay: AccountEasyPay) -> AccountEasyPayFundableType
    func easyPayFundableType(for amount: AmountEntity, operationDate: Date, accountEasyPay: AccountEasyPay) -> AccountEasyPayFundableType
    func easyPayFundableType(for amount: AmountEntity, accountEasyPay: AccountEasyPay) -> AccountEasyPayFundableType
}

extension AccountEasyPayChecker {
    public func easyPayFundableType(for amount: AmountEntity, transaction: EasyPayTransaction, accountEasyPay: AccountEasyPay) -> AccountEasyPayFundableType {
        guard let operationDate = transaction.operationDate, let transactionDescription = transaction.description, operationDate >= Date().getDateByAdding(days: -60), transactionDescription.lowercased().hasPrefix("recibo") else {
            return .notAllowed
        }
        return easyPayFundableType(for: amount, accountEasyPay: accountEasyPay)
    }
    
    public func easyPayFundableType(for amount: AmountEntity, operationDate: Date, accountEasyPay: AccountEasyPay) -> AccountEasyPayFundableType {
        guard operationDate >= Date().getDateByAdding(days: -60) else {
            return .notAllowed
        }
        return easyPayFundableType(for: amount, accountEasyPay: accountEasyPay)
    }
    
    public func easyPayFundableType(for amount: AmountEntity, accountEasyPay: AccountEasyPay) -> AccountEasyPayFundableType {
        guard let amount = amount.value.map(abs) else { return .notAllowed }
        if let grantedAmount = accountEasyPay.grantedHighAmount?.value,
            amount >= accountEasyPay.accountEasyPayLowAmountLimit,
            grantedAmount >= accountEasyPay.accountEasyPayLowAmountLimit {
            return .high
        } else if let grantedAmount = accountEasyPay.grantedLowAmount?.value,
            amount < accountEasyPay.accountEasyPayLowAmountLimit,
            amount >= accountEasyPay.accountEasyPayMinAmount,
            grantedAmount >= accountEasyPay.accountEasyPayMinAmount {
            return .low
        }
        return .notAllowed
    }
    
    public func easyPayFundableType(for amount: AmountRepresentable, accountEasyPay: AccountEasyPay) -> AccountEasyPayFundableType {
        guard let amount = amount.value.map(abs) else { return .notAllowed }
        if let grantedAmount = accountEasyPay.grantedHighAmount?.value,
            amount >= accountEasyPay.accountEasyPayLowAmountLimit,
            grantedAmount >= accountEasyPay.accountEasyPayLowAmountLimit {
            return .high
        } else if let grantedAmount = accountEasyPay.grantedLowAmount?.value,
            amount < accountEasyPay.accountEasyPayLowAmountLimit,
            amount >= accountEasyPay.accountEasyPayMinAmount,
            grantedAmount >= accountEasyPay.accountEasyPayMinAmount {
            return .low
        }
        return .notAllowed
    }
}
