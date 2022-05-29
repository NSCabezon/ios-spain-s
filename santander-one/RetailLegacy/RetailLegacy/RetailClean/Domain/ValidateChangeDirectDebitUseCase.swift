import SANLegacyLibrary
import CoreFoundationLib

class ValidateChangeDirectDebitUseCase: UseCase<Void, ValidateChangeDirectDebitUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ValidateChangeDirectDebitUseCaseOkOutput, StringErrorOutput> {
        let response = try provider.getBsanSignatureManager().consultBillAndTaxesSignaturePositions()
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
        }
        guard let signatureWithToken = SignatureWithToken(dto: dto) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(ValidateChangeDirectDebitUseCaseOkOutput(signatureWithToken: signatureWithToken))
    }
}

struct ValidateChangeDirectDebitUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}
