//
//  InternalDeferredTransferSummaryPresenter.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 19/01/2020.
//

import Foundation
import Operative

final class InternalDeferredTransferSummaryPresenter: InternalTransferSummaryPresenter {
    private lazy var internalTransferModifier = self.dependenciesResolver.resolve(forOptionalType: InternalTransferModifierProtocol.self)
    
    override func buildContent() -> [OperativeSummaryStandardBodyItemViewModel] {
        let builder = InternalDeferredTransferSummaryContentBuilder(operativeData: self.operativeData, dependenciesResolver: self.dependenciesResolver)
        guard let internalTransferModifier = internalTransferModifier else {
            return getDeferredSummaryContent(for: builder)
        }
        return getDeferredSummaryContent(for: builder, transferModifier: internalTransferModifier)
    }
}

private extension InternalDeferredTransferSummaryPresenter {
    func getDeferredSummaryContent(for builder: InternalDeferredTransferSummaryContentBuilder) -> [OperativeSummaryStandardBodyItemViewModel] {
        builder.addAmountAndConcept()
        builder.addTransferType()
        builder.addOriginAccount()
        builder.addDestinationAccount()
        builder.addPeriodicityInfo()
        builder.addDeferredDate()
        builder.addMailExpenses()
        builder.addTotalAmount()
        return builder.build()
    }
    
    func getDeferredSummaryContent(for builder: InternalDeferredTransferSummaryContentBuilder, transferModifier: InternalTransferModifierProtocol) -> [OperativeSummaryStandardBodyItemViewModel] {
        return transferModifier.getDeferredSummaryContent(for: builder)
    }
}
