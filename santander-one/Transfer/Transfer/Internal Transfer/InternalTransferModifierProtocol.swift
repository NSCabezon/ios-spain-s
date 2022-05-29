//
//  InternalTransferModifierProtocol.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 6/7/21.
//

import Operative

public protocol InternalTransferModifierProtocol {
    var avaiableItemAction: Bool { get }
    var differenceOfDaysToDeferredTransfers: Int { get }
    func getPeriodicityTypes() -> [InternalTransferPeriodicityTypeViewModel]
    var isEnabledSelectorBusinessDateView: Bool { get }
    var isStandingOrderTransferSimulationEnabled: Bool { get }
    func getSummaryContent(for builder: InternalTransferSummaryContentBuilder) -> [OperativeSummaryStandardBodyItemViewModel]
    func getDeferredSummaryContent(for builder: InternalDeferredTransferSummaryContentBuilder) -> [OperativeSummaryStandardBodyItemViewModel]
    func getPeriodicSummaryContent(for builder: InternalPeriodicTransferSummaryContentBuilder) -> [OperativeSummaryStandardBodyItemViewModel]
    func getContinueTitleKey() -> String
}
