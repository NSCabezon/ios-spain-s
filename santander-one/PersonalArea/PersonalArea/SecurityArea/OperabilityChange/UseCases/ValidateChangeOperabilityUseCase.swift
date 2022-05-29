//
//  ValidateChangeOperabilityUseCase.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 19/05/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

class ValidateChangeOperabilityUseCase: UseCase<Void, ValidateChangeOperabilityUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ValidateChangeOperabilityUseCaseOkOutput, StringErrorOutput> {
        let signatureManager = provider.getBsanSignatureManager()
        let response = try signatureManager.validateSignatureActivation()
        
        if response.isSuccess(), let signatureTokenDTO = try response.getResponseData(), let signatureWithTokenEntity =  SignatureWithTokenEntity(signatureTokenDTO) {
            return UseCaseResponse.ok(ValidateChangeOperabilityUseCaseOkOutput(signatureWithToken: signatureWithTokenEntity))
        }
        
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(StringErrorOutput(errorDescription))
    }
    
}

struct ValidateChangeOperabilityUseCaseOkOutput {
    let signatureWithToken: SignatureWithTokenEntity
}
