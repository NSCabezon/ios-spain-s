//
//  InternalPeriodicTransferSummaryPresenter.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 19/01/2020.
//

import Foundation
import Operative

final class InternalPeriodicTransferSummaryPresenter: InternalTransferSummaryPresenter {
    private lazy var internalTransferModifier = self.dependenciesResolver.resolve(forOptionalType: InternalTransferModifierProtocol.self)
    
    override func buildContent() -> [OperativeSummaryStandardBodyItemViewModel] {
        let builder = InternalPeriodicTransferSummaryContentBuilder(operativeData: self.operativeData, dependenciesResolver: self.dependenciesResolver)
        guard let internalTransferModifier = internalTransferModifier else {
            return getPeriodicSummaryContent(for: builder)
        }
        return getPeriodicSummaryContent(for: builder, transferModifier: internalTransferModifier)
    }
}

private extension InternalPeriodicTransferSummaryPresenter {
    func getPeriodicSummaryContent(for builder: InternalPeriodicTransferSummaryContentBuilder) -> [OperativeSummaryStandardBodyItemViewModel] {
        builder.addAmountAndConcept()
        builder.addTransferType()
        builder.addOriginAccount()
        builder.addDestinationAccount()
        builder.addPeriodicityInfo()
        builder.addStartDate()
        builder.addEndDate()
        builder.addMailExpenses()
        builder.addTotalAmount()
        return builder.build()
    }
    
    func getPeriodicSummaryContent(for builder: InternalPeriodicTransferSummaryContentBuilder, transferModifier: InternalTransferModifierProtocol) -> [OperativeSummaryStandardBodyItemViewModel] {
        return transferModifier.getPeriodicSummaryContent(for: builder)
    }
}
