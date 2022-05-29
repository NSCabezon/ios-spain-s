//
//  Fund.swift
//  Funds
//
import CoreFoundationLib
import CoreDomain
import OpenCombine

class Fund {
    let fundRepresentable: FundRepresentable
    let fundDetailRepresentable: FundDetailRepresentable?
    let dependencies: FundsHomeDependenciesResolver
    
    init(funds: FundRepresentable, dependencies: FundsHomeDependenciesResolver) {
        self.fundRepresentable = funds
        self.fundDetailRepresentable = nil
        self.dependencies = dependencies
    }

    init(funds: FundRepresentable, detail: FundDetailRepresentable, dependencies: FundsHomeDependenciesResolver) {
        self.fundRepresentable = funds
        self.fundDetailRepresentable = detail
        self.dependencies = dependencies
    }

    var alias: String? {
        self.fundRepresentable.alias
    }

    var amount: String? {
        guard let balance = fundRepresentable.countervalueAmountRepresentable.map(AmountEntity.init) else {
            return nil
        }
        return balance.getStringValue()
    }

    var amountBigAttributedString: NSAttributedString? {
        guard let balance = fundRepresentable.valueAmountRepresentable.map(AmountEntity.init) else {
            return nil
        }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32)
        let amount = MoneyDecorator(balance, font: font)
        return amount.getFormatedCurrency()
    }

    var number: String? {
        if let customFundNumber = self.homeHeaderModifier?.getCustomNumber(for: self.fundRepresentable) {
            return customFundNumber
        }
        return self.fundRepresentable.contractDescription ?? ""
    }

    var profitabilityPercent: String {
        let decimalPercentValue = self.fundRepresentable.profitabilityPercent ?? 0
        let sign = decimalPercentValue.getSign()
        return "\(sign)\(decimalPercentValue.getDecimalFormattedValue(with: 2))%"
    }

    var profitabilityAmount: String? {
        let balance = fundRepresentable.profitabilityAmountRepresentable.map(AmountEntity.init) ?? AmountEntity(value: 0)
        return balance.getStringValue()
    }

    var ownershipType: String? {
        self.fundRepresentable.ownershipType?.uppercased()
    }

    var isOwnerViewEnabled: Bool {
        (self.homeHeaderModifier?.isOwnerViewEnabled ?? false) && (self.fundRepresentable.ownershipType?.isNotEmpty ?? false)
    }

    var isProfitabilityDataEnabled: Bool {
        self.homeHeaderModifier?.isProfitabilityDataEnabled ?? false
    }

    var isShareButtonEnabled: Bool {
        self.homeHeaderModifier?.isShareButtonEnabled ?? false
    }
}

private extension Fund {
    var homeHeaderModifier: FundsHomeHeaderModifier? {
        self.dependencies.external.resolve()
    }
}

extension Fund {
    var fundsDetailFieldsModifier: FundsDetailFieldsModifier? {
        self.dependencies.external.resolve()
    }
}

extension Fund: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.alias)
        hasher.combine(self.amount)
        hasher.combine(self.number)
    }
}

extension Fund: Equatable {
    static func == (lhs: Fund, rhs: Fund) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Fund: Shareable {
    func getShareableInfo() -> String {
        return self.number ?? ""
    }
}
