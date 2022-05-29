//
//  ConfirmScheduledInternalTransfer.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 17/01/2020.
//

import CoreFoundationLib

struct ConfirmScheduledInternalTransferUseCaseInput {
    let originAccount: AccountEntity
    let destinationAccount: AccountEntity
    let amount: AmountEntity
    let concept: String?
    let transferTime: TransferTime
    let scheduledTransfer: ValidateScheduledTransferEntity?
}

struct ConfirmInternalScheduledTransferUseCaseInput: ScheduledTransferConvertible {
    let originAccount: AccountEntity
    let destinationAccount: AccountEntity
    let amount: AmountEntity
    let concept: String?
    let time: TransferTime
    let scheduledTransfer: ValidateScheduledTransferEntity?
    let isSpanishResident: Bool
    let saveFavorites: Bool
    let alias: String?
    let name: String?
}

struct ConfirmScheduledInternalTransferUseCaseOkOutput {
    let internalTransfer: InternalTransferEntity
    let scheduledTransfer: ValidateScheduledTransferEntity?
    let scaEntity: SCAEntity
}
