import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmBillsAndTaxesUseCase: ConfirmUseCase<ConfirmBillsAndTaxesUseCaseInput, ConfirmBillsAndTaxesUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmBillsAndTaxesUseCaseInput) throws -> UseCaseResponse<ConfirmBillsAndTaxesUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let signatureWithTokenDTO = requestValues.signatureWithToken.signatureWithTokenDTO
        let accountDTO = requestValues.account.accountDTO
        let paymentBillTaxesDTO = requestValues.paymentBillTaxes.dto
        let directDebit = requestValues.directDebit
        
        let responseSignature = try provider.getBsanBillTaxesManager().confirmationSignatureBillAndTaxes(signatureWithTokenDTO: signatureWithTokenDTO)
        
        if responseSignature.isSuccess(), let billsAndTaxesTokenDTO = try responseSignature.getResponseData() {
            let response = try provider.getBsanBillTaxesManager().confirmationBillAndTaxes(chargeAccountDTO: accountDTO, paymentBillTaxesDTO: paymentBillTaxesDTO, billAndTaxesTokenDTO: billsAndTaxesTokenDTO, directDebit: directDebit)
            
            if response.isSuccess(), let paymentBillTaxesConfirmationDTO = try response.getResponseData() {
                return UseCaseResponse.ok(ConfirmBillsAndTaxesUseCaseOkOutput(paymentBillTaxesConfirmation: PaymentBillTaxesConfirmation(dto: paymentBillTaxesConfirmationDTO)))
            }
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, .otherError, errorCode))
        }
        let signatureType = try getSignatureResult(responseSignature)
        let errorDescription = try responseSignature.getErrorMessage() ?? ""
        let errorCode = try responseSignature.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmBillsAndTaxesUseCaseInput {
    let signatureWithToken: SignatureWithToken
    let account: Account
    let paymentBillTaxes: PaymentBillTaxes
    let directDebit: Bool
}

struct ConfirmBillsAndTaxesUseCaseOkOutput {
    let paymentBillTaxesConfirmation: PaymentBillTaxesConfirmation
}
