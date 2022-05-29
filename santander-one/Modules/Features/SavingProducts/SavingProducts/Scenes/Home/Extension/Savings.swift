//
//  Savings.swift
//  Savings
//
//  Created by Adrian Escriche Martin on 16/2/22.
//
import CoreFoundationLib
import CoreDomain
import OpenCombine


public class Savings {
    let savings: SavingProductRepresentable
    
    init(savings: SavingProductRepresentable) {
        self.savings = savings
    }
    
    var alias: String {
        return savings.alias?.capitalized ?? ""
    }
    
    var accountID: String {
        return savings.accountId ?? ""
    }
    
    var contractNumber: String {
        return savings.contractRepresentable?.contractNumber ?? ""
    }
    
    var identification: String {
        return savings.identification?.capitalized ?? ""
    }
    
    var accountSubtype: String {
        return savings.accountSubType ?? ""
    }
    
    var amount: String? {
        guard let balance = savings.currentBalanceRepresentable.map(AmountEntity.init) else { return nil }
        return balance.getStringValue()
    }
    
    var amountAccessibility: String? {
        return amountAccessibility(decoratedAmount?.string)
    }
    
    var decoratedAmount: NSAttributedString? {
        guard let balance = savings.currentBalanceRepresentable.map(AmountEntity.init) else { return nil }
        let font: UIFont = UIFont.santander(family: .headline, type: .bold, size: 32)
        let decimalFont: UIFont = UIFont.santander(family: .headline, type: .bold, size: 18)
        let amount: MoneyDecorator
        if #available(iOS 11.0, *) {
            amount = MoneyDecorator(balance, fontScaled: font, decimalFontScaled: decimalFont)
        } else {
            amount = MoneyDecorator(balance, font: font)
        }
        return amount.getFormattedStringWithoutMillion()
    }
    
    var balanceInclPending: String? {
        guard let balanceInclPending = savings.balanceIncludedPendingRepresentable.map(AmountEntity.init) else { return "--" }
        return balanceInclPending.getStringValue()
    }
    
    var balanceInclPendingAccessibility: String? {
        return amountAccessibility(balanceInclPending)
    }
    
    var interestRate: String? {
        guard let interestRate = savings.interestRate else { return "--" }
        return interestRate
    }

    var interestRateLinkRepresentable: InterestRateLinkRepresentable? {
        return savings.interestRateLinkRepresentable
    }
    
    var availableBalance: String? {
        guard let balanceInclPending = savings.balanceIncludedPendingRepresentable.map(AmountEntity.init) else { return "--" }
        return balanceInclPending.getStringValue()
    }
    
    var availableBalanceAccessibility: String? {
        return amountAccessibility(availableBalance)
    }
    
    var complementaryData: [DetailTitleLabelType] = []
    /// This property contains the maximum value of fields that any savings product has
    /// so the the cell knows if it has to add emtpy values to match the maximum number of fields.
    var totalNumberOfFields = 0
    /// This property contains the longest id value of all savings products
    /// so the cell knows if it is needed a two line label
    var idLabelForLengthReference = ""
    var didSelectShare: ((Savings) -> Void)?
    var didSelectBalanceInfo: ((Savings) -> Void)?
    var didSelectInterestInfo: (() -> Void)?
    var didSelectInterestRateLink: ((Savings) -> Void)?
}

extension Savings: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(accountID)
    }
}

extension Savings: Equatable {
    public static func == (lhs: Savings, rhs: Savings) -> Bool {
        return lhs.accountID == rhs.accountID
    }
}

extension Savings: Shareable {
    public func getShareableInfo() -> String {
        return savings.identification ?? ""
    }
}

private extension Savings {
    func amountAccessibility(_ string: String?) -> String? {
        guard let amountAttributeString = string else { return nil }
        var characters = Array(amountAttributeString)
        if characters.first == "-", characters.element(atIndex: 1)?.isNumber == false {
            characters.swapAt(0, 1)
            return String(characters)
        } else {
            return amountAttributeString
        }
    }
}
