//
//  GetEmittedTransferUseCaseGroupInput.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/21/19.
//

import CoreFoundationLib

struct GetEmittedTransferUseCaseGroupInput {
    let accounts: [AccountEntity]
}

struct GetEmittedTransferUseCaseGroupOutput {
    let result: [AccountEntity: [TransferEmittedEntity]]
}

struct GetReceivedTransferUseCaseGroupOutput {
    let result: [AccountEntity: [TransferReceivedEntity]]
}
