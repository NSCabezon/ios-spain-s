//
//  OnePayTransferModifierProtocol.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 27/4/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public protocol OnePayTransferModifierProtocol {
    func updateCountry(_ entity: SepaCountryInfoEntity) -> Bool
    func isImmediateEnabled(_ comission: AmountEntity?) -> Bool
    func accountCondition(_ account: AccountEntity) -> Bool
    var isDisabledUrgentType: Bool { get }
    var isEnabledDisclaimerCommissionsText: Bool { get }
    var isEnabledShowTaxTooltip: Bool { get }
    var isEnabledResidenceView: Bool { get }
    var isEnabledSelectorBusinessDateView: Bool { get }
    var isNotMandatorySCASteps: Bool { get }
    var isEnabledComissionLabel: Bool { get }
    func getNumberOfStepsForProgress(isProductSelectedWhenCreated: Bool) -> Int
    var periodicEndDate: Date { get }
    func getPeriodicityTypes() -> [SendMoneyPeriodicityTypeViewModel]
    var showSpecialPricesForNowTransfers: Bool { get }
    var showSpecialPricesForDateTransfers: Bool { get }
    var showSpecialPricesForPeriodicTransfers: Bool { get }
    var isEnabledSimulationTransfer: Bool { get }
    var isModifyAmountEnabled: Bool { get }
    var isModifyOriginAccountEnabled: Bool { get }
    var isModifyTransferTypeEnabled: Bool { get }
    var isModifyDestinationAccountEnabled: Bool { get }
    var isModifyCountryEnabled: Bool { get }
    var isModifyPeriodicityEnabled: Bool { get }
    var isModifyIssueDataEnabled: Bool { get }
    var hideAvailableAmount: Bool { get }
    var hideSummaryCommissions: Bool { get }
    var hideNetAmount: Bool { get }
    var showExecutionDateTitle: Bool { get }
    var hideEmailNotification: Bool { get }
    func getMaxLengthAliasFavorite() -> Int
    var showDescriptionHeaderSummaryScreen: Bool { get }
    var showCostsForStandingOrders: Bool { get }
    var differenceOfDaysToDeferredTransfers: Int { get }
}
