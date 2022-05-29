//
//  InternalDeferredTransferConfirmationBuilder.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 08/01/2020.
//

import Foundation
import Operative
import CoreFoundationLib

class InternalDeferredTransferConfirmationBuilder: InternalTransferConfirmationBuilder {
    
    func addPeriodicityInfo(action: ConfirmationItemAction?) {
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_periodicity"),
            value: localized("confirmation_item_timely"),
            action: action
        )
        self.items.append(item)
    }
    
    func addDeferredDate(action: ConfirmationItemAction?) {
        guard
            let time = self.internalTransfer.time,
            case .day(date: let date) = time
        else {
            return
        }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_issuanceDate"),
            value: dependenciesResolver.resolve(for: TimeManager.self).toString(date: date, outputFormat: .dd_MMMM_YYYY) ?? "",
            action: action
        )
        self.items.append(item)
    }
    
}
