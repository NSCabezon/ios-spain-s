//
//  SendMoneyConfirmationNoSepaUseCaseProtocol.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 10/3/22.
//

import CoreFoundationLib

public protocol SendMoneyConfirmationNoSepaUseCaseProtocol: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput> {}

final class SendMoneyConfirmationNoSepaDefaultUseCase: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput>, SendMoneyConfirmationNoSepaUseCaseProtocol {
    override func executeUseCase(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        return .ok(requestValues)
    }
}
