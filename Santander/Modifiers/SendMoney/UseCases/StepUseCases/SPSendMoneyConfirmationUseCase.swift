//
//  SPSendMoneyConfirmationUseCase.swift
//  Santander
//
//  Created by Angel Abad Perez on 21/2/22.
//

import CoreFoundationLib
import TransferOperatives

final class SPSendMoneyConfirmationUseCase: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput>, SendMoneyConfirmationUseCaseProtocol {
    
    var dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        let response = try self.validateTransfer(requestValues: requestValues)
        guard response.isOkResult,
              let okResultValues = try? response.getOkResult() else {
            return .error(try response.getErrorResult())
        }
        return .ok(okResultValues)
    }
}

// MARK: - Validation transfer

extension SPSendMoneyConfirmationUseCase: SendMoneyValidationProtocol {}
