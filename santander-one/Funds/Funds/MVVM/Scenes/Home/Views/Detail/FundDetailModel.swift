//
//  FundDetailModel.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 9/3/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain

final class FundDetailModel {

    private let fund: FundRepresentable
    private let detail: FundDetailRepresentable?
    private let modifier: FundsDetailFieldsModifier?

    init(fund: FundRepresentable, detail: FundDetailRepresentable?, modifier: FundsDetailFieldsModifier?) {
        self.fund = fund
        self.detail = detail
        self.modifier = modifier
    }

    var sections: [FundDetailSectionModel] {
        guard let modifier = modifier,
              let sections = modifier.getDetailFields(for: fund, detail: detail) else {
            return []
        }
        return sections
    }
}

public class FundDetailSectionModel {
    let title: String?
    let hasSeparator: Bool
    var infos: [FundDetailInfoModel] = []

    init(title: String?, hasSeparator: Bool?) {
        self.title = title
        self.hasSeparator = hasSeparator ?? false
    }
}

class FundDetailInfoModel {
    let title: String
    let value: String
    let titleIdentifier: String?
    let valueIdentifier: String?
    var shareable: Bool = false
    var shareIdentifier: String?

    init(title: String, value: String, titleIdentifier: String?, valueIdentifier: String?, shareable: Bool = false, shareIdentifier: String? = nil) {
        self.title = title
        self.value = value
        self.titleIdentifier = titleIdentifier
        self.valueIdentifier = valueIdentifier
        self.shareable = shareable
        self.shareIdentifier = shareIdentifier
    }
}

public final class FundDetailBuilder {
    public init() {}
    private var sections: [FundDetailSectionModel] = []

    public func addSection(title: String = "", hasSeparator: Bool = false) -> Self {
        sections.append(FundDetailSectionModel(title: title, hasSeparator: hasSeparator))
        return self
    }

    public func addAssociatedAccount(_ account: String?, shareable: Bool = false) -> Self {
        if let account = account {
            let info = FundDetailInfoModel(title: localized("funds_label_associatedAccount"),
                                           value: account,
                                           titleIdentifier: AccessibilityIDFundDetail.detailAssociatedAccount.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailAssociatedAccountValue.rawValue,
                                           shareable: shareable,
                                           shareIdentifier: localized("voiceover_shareAssociatedAccount"))
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addAlias(_ alias: String?) -> Self {
        if let alias = alias {
            let info = FundDetailInfoModel(title: localized("funds_label_fundAlias"),
                                           value: alias,
                                           titleIdentifier: AccessibilityIDFundDetail.detailAlias.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailAliasValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addOwner(_ owner: String?) -> Self {
        if let owner = owner {
            let info = FundDetailInfoModel(title: localized("funds_label_owner"),
                                           value: owner,
                                           titleIdentifier: AccessibilityIDFundDetail.detailOwner.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailOwnerValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addDescription(_ description: String?) -> Self {
        if let description = description {
            let info = FundDetailInfoModel(title: localized("funds_label_description"),
                                           value: description,
                                           titleIdentifier: AccessibilityIDFundDetail.detailDescription.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailDescriptionValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addValuationDate(_ valuationDate: String?) -> Self {
        if let valuationDate = valuationDate {
            let info = FundDetailInfoModel(title: localized("funds_label_dateValuation"),
                                           value: valuationDate,
                                           titleIdentifier: AccessibilityIDFundDetail.detailDateOfValuation.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailDateOfValuationValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addNumberOfUnits(_ numberOfUnits: String?) -> Self {
        if let numberOfUnits = numberOfUnits {
            let info = FundDetailInfoModel(title: localized("funds_label_numberUnits"),
                                           value: numberOfUnits,
                                           titleIdentifier: AccessibilityIDFundDetail.detailNumberOfUnits.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailNumberOfUnitsValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addValueOfAUnit(_ valueOfAUnit: String?) -> Self {
        if let valueOfAUnit = valueOfAUnit {
            let info = FundDetailInfoModel(title: localized("funds_label_valueUnit"),
                                           value: valueOfAUnit,
                                           titleIdentifier: AccessibilityIDFundDetail.detailValueOfAUnit.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailValueOfAUnitValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addTotalValue(_ totalValue: String?) -> Self {
        if let totalValue = totalValue {
            let info = FundDetailInfoModel(title: localized("funds_label_totalValue"),
                                           value: totalValue,
                                           titleIdentifier: AccessibilityIDFundDetail.detailTotalValue.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailTotalValueValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addCategoryOfTheUnit(_ categoryOfTheUnit: String?) -> Self {
        if let categoryOfTheUnit = categoryOfTheUnit {
            let info = FundDetailInfoModel(title: localized("funds_label_categoryUnit"),
                                           value: categoryOfTheUnit,
                                           titleIdentifier: AccessibilityIDFundDetail.detailCategoryOfAUnit.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailCategoryOfAUnitValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addUnusedIsaAllowance(_ unusedIsaAllowance: String?) -> Self {
        if let unusedIsaAllowance = unusedIsaAllowance {
            let info = FundDetailInfoModel(title: localized("funds_label_unusedIsaAllowance"),
                                           value: unusedIsaAllowance,
                                           titleIdentifier: AccessibilityIDFundDetail.detailUnusedIsaAllowance.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailUnusedIsaAllowanceValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addIsaWrapInPlace(_ isaWrapInPlace: String?) -> Self {
        if let isaWrapInPlace = isaWrapInPlace {
            let info = FundDetailInfoModel(title: localized("funds_label_isaWrap"),
                                           value: isaWrapInPlace,
                                           titleIdentifier: AccessibilityIDFundDetail.detailIsaWrapInPlace.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailIsaWrapInPlaceValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addFeesByDirectDebit(_ feesByDirectDebit: String?) -> Self {
        if let feesByDirectDebit = feesByDirectDebit {
            let info = FundDetailInfoModel(title: localized("funds_label_feesDirectDebit"),
                                           value: feesByDirectDebit,
                                           titleIdentifier: AccessibilityIDFundDetail.detailFeesByDirectDebit.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailFeesByDirectDebitValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addDividendReinvestment(_ dividendReinvestment: String?) -> Self {
        if let dividendReinvestment = dividendReinvestment {
            let info = FundDetailInfoModel(title: localized("funds_label_dividendReinvestment"),
                                           value: dividendReinvestment,
                                           titleIdentifier: AccessibilityIDFundDetail.detailDividendReinvestment.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailDividendReinvestmentValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addBalance(_ balance: String?) -> Self {
        if let balance = balance {
            let info = FundDetailInfoModel(title: localized("funds_label_balance"),
                                           value: balance,
                                           titleIdentifier: AccessibilityIDFundDetail.detailBalance.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailBalanceValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addCurrentValueAmount(_ currentValueAmount: String?) -> Self {
        if let currentValueAmount = currentValueAmount {
            let info = FundDetailInfoModel(title: localized("funds_label_currentValue"),
                                           value: currentValueAmount,
                                           titleIdentifier: AccessibilityIDFundDetail.detailCurrentValue.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailCurrentValueAmountValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addPriceAtLast(_ priceAtLast: String?) -> Self {
        if let priceAtLast = priceAtLast {
            let info = FundDetailInfoModel(title: localized("funds_label_priceAtLast"),
                                           value: priceAtLast,
                                           titleIdentifier: AccessibilityIDFundDetail.detailPriceAtLast.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailPriceAtLastValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addUnits(_ units: String?) -> Self {
        if let units = units {
            let info = FundDetailInfoModel(title: localized("funds_label_units"),
                                           value: units,
                                           titleIdentifier: AccessibilityIDFundDetail.detailUnits.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailUnitsValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func addCurrentValue(_ currentValue: String?) -> Self {
        if let currentValue = currentValue {
            let info = FundDetailInfoModel(title: localized("funds_label_currentValue"),
                                           value: currentValue,
                                           titleIdentifier: AccessibilityIDFundDetail.detailCurrentValue.rawValue,
                                           valueIdentifier: AccessibilityIDFundDetail.detailCurrentValueValue.rawValue)
            sections.last?.infos.append(info)
        }
        return self
    }

    public func build() -> [FundDetailSectionModel] {
        return self.sections
    }
}
