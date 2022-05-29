import CoreFoundationLib
import SANLegacyLibrary

class ConfirmExtraordinaryContributionUseCase: ConfirmUseCase<ConfirmExtraordinaryContributionUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmExtraordinaryContributionUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let pensionsManager = provider.getBsanPensionsManager()
        
        let pensionDTO = requestValues.pension.pensionDTO
        let amountDTO = requestValues.amount.amountDTO
        let signatureWithToken = requestValues.signatureToken
        let signatureWithTokenDTO = SignatureWithTokenDTO(signatureDTO: signatureWithToken.signature.dto, magicPhrase: signatureWithToken.magicPhrase)
        
        let response = try pensionsManager.confirmExtraordinaryContribution(pensionDTO: pensionDTO, amountDTO: amountDTO, signatureWithTokenDTO: signatureWithTokenDTO)
        
        if response.isSuccess() {
            return UseCaseResponse.ok()
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmExtraordinaryContributionUseCaseInput {
    let pension: Pension
    let amount: Amount
    let signatureToken: SignatureWithToken
}
