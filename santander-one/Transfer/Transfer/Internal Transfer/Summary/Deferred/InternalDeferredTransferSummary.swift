//
//  InternalDeferredTransferSummary.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 19/01/2020.
//

import Operative
import Foundation
import CoreFoundationLib

public final class InternalDeferredTransferSummaryContentBuilder: InternalTransferSummaryContentBuilder {
    
    public func addPeriodicityInfo() {
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("confirmation_item_periodicity"),
            subTitle: localized("confirmation_label_delayed")
        )
        self.items.append(item)
    }
    
    public func addDeferredDate() {
        guard
            let time = self.operativeData.time,
            case .day(date: let date) = time
        else {
            return
        }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("summary_item_issuanceDate"),
            subTitle: self.dependenciesResolver.resolve(for: TimeManager.self).toString(date: date, outputFormat: .dd_MMMM_YYYY) ?? ""
        )
        self.items.append(item)
    }
}
