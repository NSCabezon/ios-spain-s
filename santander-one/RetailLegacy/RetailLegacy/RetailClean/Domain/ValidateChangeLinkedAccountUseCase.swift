import SANLegacyLibrary
import CoreFoundationLib

class ValidateChangeLinkedAccountUseCase: UseCase<Void, ValidateChangeLinkedAccountUseCaseOkOutput, ValidateChangeLinkedAccountUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ValidateChangeLinkedAccountUseCaseOkOutput, ValidateChangeLinkedAccountUseCaseErrorOutput> {
        
        let signatureManager = provider.getBsanSignatureManager()
        let response = try signatureManager.validateSignatureActivation()
        
        if response.isSuccess(), let signatureTokenDTO = try response.getResponseData(), let signature = signatureTokenDTO.signatureDTO {
            return UseCaseResponse.ok(ValidateChangeLinkedAccountUseCaseOkOutput(signature: signature))
        }
        
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(ValidateChangeLinkedAccountUseCaseErrorOutput(errorDescription))
    }
    
}

struct ValidateChangeLinkedAccountUseCaseOkOutput {
    let signature: SignatureDTO
}

class ValidateChangeLinkedAccountUseCaseErrorOutput: StringErrorOutput {
    
}
