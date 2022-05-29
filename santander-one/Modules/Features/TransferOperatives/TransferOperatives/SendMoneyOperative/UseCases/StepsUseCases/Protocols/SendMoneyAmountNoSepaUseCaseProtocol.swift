//
//  SendMoneyAmountNoSepaUseCaseProtocol.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 23/2/22.
//

import CoreFoundationLib

public protocol SendMoneyAmountNoSepaUseCaseProtocol: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput> {}

final class SendMoneyAmountNoSepaDefaultUseCase: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput>, SendMoneyAmountNoSepaUseCaseProtocol {
    override func executeUseCase(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        return .ok(requestValues)
    }
}
