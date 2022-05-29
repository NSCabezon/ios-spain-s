//
import SANLegacyLibrary
import CoreFoundationLib

class ConfirmChangeLinkedAccountUseCase: UseCase<ConfirmChangeLinkedAccountUseCaseInput, ConfirmChangeLinkedAccountUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmChangeLinkedAccountUseCaseInput) throws -> UseCaseResponse<ConfirmChangeLinkedAccountUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let signatureResponse = try provider.getBsanLoansManager().confirmChangeAccount(loanDTO: requestValues.loan.loanDTO, accountDTO: requestValues.account.accountDTO, signatureDTO: requestValues.signature.dto)
        
        if signatureResponse.isSuccess() {
            return UseCaseResponse.ok(ConfirmChangeLinkedAccountUseCaseOkOutput())
        }
        let signatureType = try getSignatureResult(signatureResponse)
        let errorDescription = try signatureResponse.getErrorMessage() ?? ""
        let errorCode = try signatureResponse.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmChangeLinkedAccountUseCaseInput {
    let signature: Signature
    let loan: Loan
    let account: Account    
}

struct ConfirmChangeLinkedAccountUseCaseOkOutput {

}
