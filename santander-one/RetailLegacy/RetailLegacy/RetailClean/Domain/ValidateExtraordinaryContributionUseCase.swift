import CoreFoundationLib
import SANLegacyLibrary

class ValidateExtraordinaryContributionUseCase: UseCase<Void, ValidateExtraordinaryContributionUseCaseOkOutput, ValidateExtraordinaryContributionUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ValidateExtraordinaryContributionUseCaseOkOutput, ValidateExtraordinaryContributionUseCaseErrorOutput> {

        let response = try provider.getBsanSignatureManager().consultPensionSignaturePositions()
        
        if response.isSuccess(), let signatureWithTokenDTO = try response.getResponseData(), let signatureWithToken = SignatureWithToken(dto: signatureWithTokenDTO) {
            return UseCaseResponse.ok(ValidateExtraordinaryContributionUseCaseOkOutput(signatureWithToken: signatureWithToken))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(ValidateExtraordinaryContributionUseCaseErrorOutput(errorDescription))
    }
}

struct ValidateExtraordinaryContributionUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}

class ValidateExtraordinaryContributionUseCaseErrorOutput: StringErrorOutput {
    
}
