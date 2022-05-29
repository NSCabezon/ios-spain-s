//
//  ValidateOTPNoSepaUseCaseProtocol.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 15/3/22.
//

import CoreFoundationLib
import CoreDomain

public protocol ValidateOTPNoSepaUseCaseProtocol: UseCase<ValidateOTPNoSepaInput, ValidateOTPNoSepaOkOutput, StringErrorOutput> {}

final class ValidateOTPNoSepaDefaultUseCase: UseCase<ValidateOTPNoSepaInput, ValidateOTPNoSepaOkOutput, StringErrorOutput>, ValidateOTPNoSepaUseCaseProtocol {
    override func executeUseCase(requestValues: ValidateOTPNoSepaInput) throws -> UseCaseResponse<ValidateOTPNoSepaOkOutput, StringErrorOutput> {
        return .ok(ValidateOTPNoSepaOkOutput(otp: nil))
    }
}

public struct ValidateOTPNoSepaInput {
    public let operativeData: SendMoneyOperativeData
    public let signatureRepresentable: SignatureRepresentable
}

public struct ValidateOTPNoSepaOkOutput {
    public let otp: OTPValidationRepresentable?
    
    public init(otp: OTPValidationRepresentable?) {
        self.otp = otp
    }
}
