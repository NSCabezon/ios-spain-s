//
//  ScheduledTransferListEntity.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 2/10/20.
//

import Foundation

public final class ScheduledTransferListEntity {
    private let transfers: [AccountEntity: [ScheduledTransferEntity]]
    
    public init(_ transfers: [AccountEntity: [ScheduledTransferEntity]]) {
        self.transfers = transfers
    }
    
    public var scheduledTransfers: [AccountEntity: [ScheduledTransferEntity]] {
        return self.transfers.mapValues { $0.filter { $0.isScheduledTransfer } }
    }
    
    public var periodicTransfers: [AccountEntity: [ScheduledTransferEntity]] {
        return self.transfers.mapValues { $0.filter { $0.isPeriodic } }
    }
}
