//
//  GetAllRecentTransfersManager.swift
//  Transfer
//
//  Created by Alvaro Royo on 20/5/21.
//

import CoreFoundationLib
import SANLegacyLibrary

public typealias EmittedResult = [AccountEntity: [TransferEmittedEntity]]
public typealias ReceivedResult = [AccountEntity: [TransferReceivedEntity]]

public struct GetAllTransfersUseCaseInput {
    public let accounts: [AccountEntity]
    
    public init(accounts: [AccountEntity]) {
        self.accounts = accounts
    }
}

public protocol GetAllTransfersUseCaseProtocol: UseCase<GetAllTransfersUseCaseInput, (EmittedResult, ReceivedResult), StringErrorOutput> {}
public protocol GetTransferUseCaseProtocol: UseCase<TransferViewModel, TransferDetailConfiguration, StringErrorOutput> {}
