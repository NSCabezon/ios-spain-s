//
//  SendMoneyAmountUseCaseProtocol.swift
//  TransferOperatives
//
//  Created by David Gálvez Alonso on 2/2/22.
//

import CoreFoundationLib

public protocol SendMoneyAmountUseCaseProtocol: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput> {}

final class SendMoneyAmountDefaultUseCase: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput>, SendMoneyAmountUseCaseProtocol {
    override func executeUseCase(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        return .ok(requestValues)
    }
}
