//
//  SendMoneyDestinationUseCaseProtocol.swift
//  TransferOperatives
//
//  Created by David Gálvez Alonso on 2/2/22.
//

import CoreFoundationLib

public protocol SendMoneyDestinationUseCaseProtocol: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, DestinationAccountSendMoneyUseCaseErrorOutput> {}

final class SendMoneyDestinationDefaultUseCase: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, DestinationAccountSendMoneyUseCaseErrorOutput>, SendMoneyDestinationUseCaseProtocol {
    override func executeUseCase(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, DestinationAccountSendMoneyUseCaseErrorOutput> {
        return .ok(requestValues)
    }
}
