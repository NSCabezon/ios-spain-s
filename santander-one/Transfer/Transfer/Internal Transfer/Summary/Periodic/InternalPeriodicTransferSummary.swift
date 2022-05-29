//
//  InternalPeriodicTransferSummary.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 19/01/2020.
//

import Operative
import Foundation
import CoreFoundationLib

public final class InternalPeriodicTransferSummaryContentBuilder: InternalTransferSummaryContentBuilder {
    
    public func addPeriodicityInfo() {
        guard
            let time = self.operativeData.time,
            case .periodic(startDate: _, endDate: _, periodicity: let periodicity, workingDayIssue: _) = time
        else {
            return
        }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("confirmation_item_periodicity"),
            subTitle: localized(periodicity.description)
        )
        self.items.append(item)
    }
    
    public func addStartDate() {
        guard
            let time = self.operativeData.time,
            case .periodic(startDate: let startDate, endDate: _, periodicity: _, workingDayIssue: _) = time
        else {
            return
        }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("confirmation_item_startDate"),
            subTitle: dependenciesResolver.resolve(for: TimeManager.self).toString(date: startDate, outputFormat: .dd_MMMM_YYYY) ?? ""
        )
        self.items.append(item)
    }
    
    public func addEndDate() {
        guard
            let time = self.operativeData.time,
            case .periodic(startDate: _, endDate: let endDate, periodicity: _, workingDayIssue: _) = time
        else {
            return
        }
        let value: String
        switch endDate {
        case .never:
            value = localized("confirmation_label_indefinite")
        case .date(let endDate):
            value = dependenciesResolver.resolve(for: TimeManager.self).toString(date: endDate, outputFormat: .dd_MMM_yyyy) ?? ""
        }
        let item = OperativeSummaryStandardBodyItemViewModel(
            title: localized("confirmation_item_endDate"),
            subTitle: value
        )
        self.items.append(item)
    }
}
