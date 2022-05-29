//
//  SendMoneyGetFeesUseCase.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 7/3/22.
//

import CoreFoundationLib

public protocol SendMoneyGetFeesUseCaseProtocol: UseCase<Void, Data?, StringErrorOutput> {}

class SendMoneyGetFeesDefaultUseCase: UseCase<Void, Data?, StringErrorOutput>, SendMoneyGetFeesUseCaseProtocol {
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Data?, StringErrorOutput> {
        return .ok(nil)
    }
}
