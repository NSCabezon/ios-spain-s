//
//  ScheduledTransfersSelectedTransferModifier.swift
//  Transfer
//
//  Created by alvola on 28/07/2021.
//

import CoreFoundationLib

public struct SelectedTransferInfo {
    public let entity: ScheduledTransferRepresentable
    public let account: AccountEntity
    public let scheduledTransferId: String?
    
    public init(entity: ScheduledTransferRepresentable, account: AccountEntity, scheduledTransferId: String?) {
        self.entity = entity
        self.account = account
        self.scheduledTransferId = scheduledTransferId
    }
}

public protocol ScheduledTransfersSelectedTransferModifierProtocol {
    func scheduledTranferDetailFor(_ viewModel: ScheduledTransferViewModelProtocol) -> SelectedTransferInfo?
    func periodicTranferDetailFor(_ viewModel: PeriodicTransferViewModelProtocol) -> SelectedTransferInfo?
}
