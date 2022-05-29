//
//  ConfirmNoSepaSendMoneyUseCaseProtocol.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 18/3/22.
//

import CoreFoundationLib
import CoreDomain
import Operative

public protocol ConfirmSendMoneyNoSepaUseCaseProtocol: UseCase<ConfirmNoSepaSendMoneyUseCaseInput, SendMoneyOperativeData, GenericErrorOTPErrorOutput> { }

final class ConfirmNoSepaSendMoneyDefaultUseCase: UseCase<ConfirmNoSepaSendMoneyUseCaseInput, SendMoneyOperativeData, GenericErrorOTPErrorOutput>, ConfirmSendMoneyNoSepaUseCaseProtocol {
    
    override func executeUseCase(requestValues: ConfirmNoSepaSendMoneyUseCaseInput) throws -> UseCaseResponse<SendMoneyOperativeData, GenericErrorOTPErrorOutput> {
        return .ok(requestValues.operativeData)
    }
}

public struct ConfirmNoSepaSendMoneyUseCaseInput {
    public let operativeData: SendMoneyOperativeData
    public let otpCode: String
    public let otpValidation: OTPValidationRepresentable
    
    public init(operativeData: SendMoneyOperativeData, otpCode: String, otpValidation: OTPValidationRepresentable) {
        self.operativeData = operativeData
        self.otpCode = otpCode
        self.otpValidation = otpValidation
    }
}
