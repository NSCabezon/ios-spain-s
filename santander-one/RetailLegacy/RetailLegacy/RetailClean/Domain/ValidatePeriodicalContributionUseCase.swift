import SANLegacyLibrary
import CoreFoundationLib

class ValidatePeriodicalContributionUseCase: UseCase<Void, ValidatePeriodicalContributionUseCaseOkOutput, ValidatePeriodicalContributionUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ValidatePeriodicalContributionUseCaseOkOutput, ValidatePeriodicalContributionUseCaseErrorOutput> {
        
        let response = try provider.getBsanSignatureManager().consultPensionSignaturePositions()
        
        if response.isSuccess(), let signatureWithTokenDTO = try response.getResponseData(), let signatureWithToken = SignatureWithToken(dto: signatureWithTokenDTO) {
            return UseCaseResponse.ok(ValidatePeriodicalContributionUseCaseOkOutput(signatureWithToken: signatureWithToken))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(ValidatePeriodicalContributionUseCaseErrorOutput(errorDescription))
    }
}

struct ValidatePeriodicalContributionUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}

class ValidatePeriodicalContributionUseCaseErrorOutput: StringErrorOutput {
    
}
