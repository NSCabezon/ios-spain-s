//
//  SpainScheduledTransfersSelectedTransferModifier.swift
//  Santander
//
//  Created by alvola on 28/07/2021.
//

import Transfer

final class SpainScheduledTransfersSelectedTransferModifier: ScheduledTransfersSelectedTransferModifierProtocol {
    func scheduledTranferDetailFor(_ viewModel: ScheduledTransferViewModelProtocol) -> SelectedTransferInfo? {
        guard let model = viewModel as? ScheduledTransferViewModel else { return nil }
        return SelectedTransferInfo(entity: model.entity,
                                    account: model.account,
                                    scheduledTransferId: nil)
    }
    
    func periodicTranferDetailFor(_ viewModel: PeriodicTransferViewModelProtocol) -> SelectedTransferInfo? {
        guard let model = viewModel as? PeriodicTransferViewModel else { return nil }
        return SelectedTransferInfo(entity: model.entity,
                                    account: model.account,
                                    scheduledTransferId: nil)
    }
}
