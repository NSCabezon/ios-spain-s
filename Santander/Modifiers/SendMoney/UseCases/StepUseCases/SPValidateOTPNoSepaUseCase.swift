//
//  SPValidateOTPNoSepaUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 15/3/22.
//

import CoreFoundationLib
import TransferOperatives
import SANSpainLibrary

final class SPValidateOTPNoSepaUseCase: UseCase<ValidateOTPNoSepaInput, ValidateOTPNoSepaOkOutput, StringErrorOutput>, ValidateOTPNoSepaUseCaseProtocol {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ValidateOTPNoSepaInput) throws -> UseCaseResponse<ValidateOTPNoSepaOkOutput, StringErrorOutput> {
        guard let input = self.getNoSepaTransferInput(requestValues: requestValues.operativeData),
              let validationIntNoSepa = requestValues.operativeData.noSepaTransferValidation
        else { return .error(StringErrorOutput(nil)) }
        let transferRepository: SpainTransfersRepository = self.dependenciesResolver.resolve()
        let result = try transferRepository.validateOtpNoSepa(input: input, validationIntNoSepa: validationIntNoSepa, signature: requestValues.signatureRepresentable)
        switch result {
        case .success(let otpValidationRepresentable):
            return .ok(ValidateOTPNoSepaOkOutput(otp: otpValidationRepresentable))
        case .failure(let error):
            let error = error as NSError
            let signatureType = try transferRepository.processSendMoneySignatureResult(error)
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(error.localizedDescription, signatureType, error.errorCode))
        }
    }
}

extension SPValidateOTPNoSepaUseCase: SendMoneyNoSEPAInputCreatorCapable { }
