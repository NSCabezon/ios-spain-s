//
//  SendMoneyConfirmationUseCaseProtocol.swift
//  TransferOperatives
//
//  Created by David Gálvez Alonso on 2/2/22.
//

import CoreFoundationLib

public protocol SendMoneyConfirmationUseCaseProtocol: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput> {}

final class SendMoneyConfirmationDefaultUseCase: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput>, SendMoneyConfirmationUseCaseProtocol {
    override func executeUseCase(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        return .ok(requestValues)
    }
}
