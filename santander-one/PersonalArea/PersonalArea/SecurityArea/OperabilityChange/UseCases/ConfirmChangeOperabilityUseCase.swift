//
//  ConfirmChangeOperabilityUseCase.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 20/05/2020.
//

import CoreFoundationLib
import SANLegacyLibrary
import Operative

class ConfirmChangeOperabilityUseCase: UseCase<ConfirmChangeOperabilityUseCaseInput, Void, GenericErrorOTPErrorOutput>, OTPUseCaseProtocol {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmChangeOperabilityUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        let signatureManager = provider.getBsanSignatureManager()
        let response = try signatureManager.confimOperabilityChange(newOperabilityInd: requestValues.operabilityInd.rawValue, otpValidationDTO: requestValues.otpValidationDTO, otpCode: requestValues.otpCode)

        if response.isSuccess() {
            return .ok()
        } else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
    }
}

struct ConfirmChangeOperabilityUseCaseInput {
    let operabilityInd: OperabilityInd
    let otpValidationDTO: OTPValidationDTO
    let otpCode: String
}
