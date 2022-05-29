//
//  FundMovementDetails.swift
//  Funds
//

import CoreFoundationLib
import CoreDomain

struct FundMovementDetails {
    let fund: FundRepresentable
    let movement: FundMovementRepresentable
    let movementDetails: FundMovementDetailRepresentable?
    var homeCoordinator: FundsHomeCoordinator?
    var transactionsCoordinator: FundTransactionsCoordinator?
    private let modifier: FundMovementDetailFieldsModifier?
    private let trackerShareEvent: () -> Void

    init(fund: FundRepresentable, movement: FundMovementRepresentable, movementDetails: FundMovementDetailRepresentable?, homeDependencies: FundsHomeDependenciesResolver) {
        self.fund = fund
        self.movement = movement
        self.movementDetails = movementDetails
        self.homeCoordinator = homeDependencies.resolve()
        self.modifier = homeDependencies.external.common.resolve()
        self.trackerShareEvent = {
            let trackerManager: TrackerManager = homeDependencies.external.resolve()
            trackerManager.trackEvent(screenId: FundPage().page, eventId: FundPage.Action.share.rawValue, extraParameters: [:])
        }
    }

    init(fund: FundRepresentable, movement: FundMovementRepresentable, movementDetails: FundMovementDetailRepresentable?, transactionsDependencies: FundTransactionsDependenciesResolver) {
        self.fund = fund
        self.movement = movement
        self.movementDetails = movementDetails
        self.transactionsCoordinator = transactionsDependencies.resolve()
        self.modifier = transactionsDependencies.external.common.resolve()
        self.trackerShareEvent = {
            let trackerManager: TrackerManager = transactionsDependencies.external.resolve()
            trackerManager.trackEvent(screenId: FundTransactionsPage().page, eventId: FundTransactionsPage.Action.share.rawValue, extraParameters: [:])
        }
    }

    func didSelectShare() {
        self.trackerShareEvent()
        self.homeCoordinator?.share(self, type: .text)
        self.transactionsCoordinator?.share(self, type: .text)
    }

    var details: [FundMovementDetailsInfoModel] {
        guard let modifier = modifier,
              let sections = modifier.getDetailFields(for: fund, movement: movement, detail: movementDetails) else {
            return []
        }
        return sections
    }
}

extension FundMovementDetails: Shareable {
    func getShareableInfo() -> String {
        var shareableInfo = ""
        self.add(toShareableInfo: &shareableInfo, parameter: self.movement.nameRepresentable)
        self.add(toShareableInfo: &shareableInfo, title: localized("share_item_executionDate"), parameter: self.movement.dateRepresentable?.toString("dd MM yyyy"))
        self.add(toShareableInfo: &shareableInfo, title: localized("share_item_submittedDate"), parameter: self.movement.submittedDateRepresentable?.toString("dd MM yyyy"))
        var amountShareable: String?
        if let amount = self.movement.amountRepresentable, let amountValue = amount.value, let amountCurrency = amount.currencyRepresentable?.currencyName {
            amountShareable = "\(amountValue) \(amountCurrency)"
        }
        self.add(toShareableInfo: &shareableInfo, title: "Amount", parameter: amountShareable)
        self.add(toShareableInfo: &shareableInfo, title: localized("funds_label_numberUnits"), parameter: self.movement.unitsRepresentable)
        self.details.forEach({
            self.add(toShareableInfo: &shareableInfo, title: $0.title, parameter: $0.value)
        })
        return shareableInfo
    }
}

private extension FundMovementDetails {
    func add(toShareableInfo shareableInfo: inout String, title: String? = nil, parameter: String?) {
        guard let parameter = parameter else { return }
        let title = title.isNil ? "" : "\(title ?? "") "
        shareableInfo.append("\n\(title)\(parameter)")
    }
}

public class FundMovementDetailsInfoModel {
    let title: String
    let value: String
    let titleIdentifier: String?
    let valueIdentifier: String?

    init(title: String, value: String, titleIdentifier: String?, valueIdentifier: String?) {
        self.title = title
        self.value = value
        self.titleIdentifier = titleIdentifier
        self.valueIdentifier = valueIdentifier
    }
}

public final class FundMovementDetailsBuilder {
    public init() {}
    private var infos: [FundMovementDetailsInfoModel] = []

    public func addAlias(_ alias: String?) -> Self {
        if let alias = alias {
            let info = FundMovementDetailsInfoModel(title: localized("funds_label_fundAlias"),
                                           value: alias,
                                           titleIdentifier: AccessibilityIDFundMovementDetail.detailAlias.rawValue,
                                           valueIdentifier: AccessibilityIDFundMovementDetail.detailAliasValue.rawValue)
            infos.append(info)
        }
        return self
    }

    public func addAssociatedAccount(_ account: String?) -> Self {
        if let account = account {
            let info = FundMovementDetailsInfoModel(title: localized("funds_label_associatedAccount"),
                                           value: account,
                                           titleIdentifier: AccessibilityIDFundMovementDetail.detailAssociatedAccount.rawValue,
                                           valueIdentifier: AccessibilityIDFundMovementDetail.detailAssociatedAccountValue.rawValue)
            infos.append(info)
        }
        return self
    }

    public func addTransactionFees(_ transactionFees: String?) -> Self {
        if let transactionFees = transactionFees {
            let info = FundMovementDetailsInfoModel(title: localized("funds_label_transactionFees"),
                                           value: transactionFees,
                                           titleIdentifier: AccessibilityIDFundMovementDetail.detailFees.rawValue,
                                           valueIdentifier: AccessibilityIDFundMovementDetail.detailFeesValue.rawValue)
            infos.append(info)
        }
        return self
    }

    public func addStatus(_ status: String?) -> Self {
        if let status = status {
            let info = FundMovementDetailsInfoModel(title: localized("funds_label_status"),
                                           value: status,
                                           titleIdentifier: AccessibilityIDFundMovementDetail.detailStatus.rawValue,
                                           valueIdentifier: AccessibilityIDFundMovementDetail.detailStatusValue.rawValue)
            infos.append(info)
        }
        return self
    }

    public func build() -> [FundMovementDetailsInfoModel] {
        return self.infos
    }
}

