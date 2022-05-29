import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmCancelDirectBillingUseCase: ConfirmUseCase<ConfirmCancelDirectBillingUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmCancelDirectBillingUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let signatureDTO = requestValues.signature.dto
        let accountDTO = requestValues.account.accountDTO
        let billDTO = requestValues.bill.billDTO
        let cancelDirectBilling = requestValues.cancelDirectBilling.cancelDirectBillingDTO
        
        let response = try provider.getBsanBillTaxesManager().confirmCancelDirectBilling(account: accountDTO, bill: billDTO, signature: signatureDTO, getCancelDirectBillingDTO: cancelDirectBilling)
        
        if response.isSuccess() {
            return UseCaseResponse.ok()
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmCancelDirectBillingUseCaseInput {
    let signature: Signature
    let account: Account
    let bill: Bill
    let cancelDirectBilling: CancelDirectBilling
}
