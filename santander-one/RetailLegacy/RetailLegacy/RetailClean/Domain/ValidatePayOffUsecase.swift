import SANLegacyLibrary
import CoreFoundationLib

final class ValidatePayOffUsecase: UseCase<Void, ValidatePayOffUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(_ managerProvider: BSANManagersProvider) {
        self.provider = managerProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ValidatePayOffUseCaseOkOutput, StringErrorOutput> {
        
        let response = try provider.getBsanSignatureManager().consultCardsPayOffSignaturePositions()
        
        guard response.isSuccess(), let data = try response.getResponseData(), let signature = SignatureWithToken(dto: data)  else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        
        return UseCaseResponse.ok(ValidatePayOffUseCaseOkOutput(depositMoneyIntoCardSignatureToken: signature))
    }
}

struct ValidatePayOffUseCaseOkOutput {
    let depositMoneyIntoCardSignatureToken: SignatureWithToken
}
