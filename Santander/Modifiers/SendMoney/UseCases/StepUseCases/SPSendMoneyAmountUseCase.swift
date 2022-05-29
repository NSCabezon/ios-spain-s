//
//  SPSendMoneyAmountUseCase.swift
//  Santander
//
//  Created by David Gálvez Alonso on 7/2/22.
//

import CoreFoundationLib
import TransferOperatives

final class SPSendMoneyAmountUseCase: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput>, SendMoneyAmountUseCaseProtocol {
    
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
        let feeResponse = try self.getTransferFeeType(requestValues: okResultValues)
        guard feeResponse.isOkResult,
              let okFeeResultValues = try? feeResponse.getOkResult() else {
            return .error(try feeResponse.getErrorResult())
        }
        return .ok(okFeeResultValues)
    }
}

// MARK: - Validation transfer

extension SPSendMoneyAmountUseCase: SendMoneyValidationProtocol {}

// MARK: - Transfer Fee Type transfer

extension SPSendMoneyAmountUseCase: SendMoneyTransferFeeTypeProtocol {}
