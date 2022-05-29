//
//  SPSendMoneyConfirmationNoSepaUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 10/3/22.
//

import CoreFoundationLib
import TransferOperatives
import SANSpainLibrary

final class SPSendMoneyConfirmationNoSepaUseCase: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput>, SendMoneyConfirmationNoSepaUseCaseProtocol {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        let result = try self.validateNoSepa(requestValues: requestValues)
        guard result.isOkResult,
              let okResult = try? result.getOkResult()
        else {
            return .error(try result.getErrorResult())
        }
        return .ok(okResult)
    }
}

extension SPSendMoneyConfirmationNoSepaUseCase: SPSendMoneyNoSepaValidateProtocol { }
