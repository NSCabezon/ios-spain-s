//
//  ValidateOTPOperabilityUseCase.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 19/05/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

class ValidateOTPOperabilityUseCase: UseCase<ValidateOTPOperabilityUseCaseInput, ValidateOTPOperabilityUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ValidateOTPOperabilityUseCaseInput) throws -> UseCaseResponse<ValidateOTPOperabilityUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let signatureManager = provider.getBsanSignatureManager()
        let signatureWithTokenDTO = requestValues.signatureWithTokenEntity.signatureWithTokenDTO
        let response = try signatureManager.validateOTPOperability(newOperabilityInd: requestValues.operabilityInd.rawValue,
                                                                   signatureWithTokenDTO: signatureWithTokenDTO)
        
        if response.isSuccess(), let signatureTokenDTO = try response.getResponseData() {
            return .ok(ValidateOTPOperabilityUseCaseOkOutput(otpValidationEntity: OTPValidationEntity(signatureTokenDTO)))
        }
        
        let signatureType = try processSignatureResult(response)
        if var otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                otpValidationOTP.otpExcepted = true
                return .ok(ValidateOTPOperabilityUseCaseOkOutput(otpValidationEntity: OTPValidationEntity(otpValidationOTP)))
            } else {
                return .ok(ValidateOTPOperabilityUseCaseOkOutput(otpValidationEntity: OTPValidationEntity(otpValidationOTP)))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ValidateOTPOperabilityUseCaseInput {
    let operabilityInd: OperabilityInd
    let signatureWithTokenEntity: SignatureWithTokenEntity

}

struct ValidateOTPOperabilityUseCaseOkOutput {
    let otpValidationEntity: OTPValidationEntity
}
