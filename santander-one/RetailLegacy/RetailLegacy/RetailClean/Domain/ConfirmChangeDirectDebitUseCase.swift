import SANLegacyLibrary
import CoreFoundationLib

class ConfirmChangeDirectDebitUseCase: ConfirmUseCase<ConfirmChangeDirectDebitUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmChangeDirectDebitUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let manager = provider.getBsanBillTaxesManager()
        let response = try manager.confirmChangeDirectDebit(account: requestValues.destinationAccount.accountDTO, bill: requestValues.bill.billDTO, signature: requestValues.signature.signatureWithTokenDTO)
        if response.isSuccess() {
            return UseCaseResponse.ok()
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmChangeDirectDebitUseCaseInput {
    let bill: Bill
    let destinationAccount: Account
    let signature: SignatureWithToken
}
