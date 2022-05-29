import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmChangeMassiveDirectDebitsUseCase: UseCase<ConfirmChangeMassiveDirectDebitsUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    
    let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmChangeMassiveDirectDebitsUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let accountDTO = requestValues.originAccount.accountDTO
        let signatureDTO = requestValues.signature.signatureWithTokenDTO
        let response = try bsanManagersProvider.getBsanBillTaxesManager().confirmChangeMassiveDirectDebitsAccount(originAccount: accountDTO, signature: signatureDTO)
        let signatureType = try getSignatureResult(response)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            if errorCode == "K8_1095" {
                return .error(GenericErrorSignatureErrorOutput("receipts_alert_text_selectOtherAccount", signatureType, errorCode))
            }
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
        return .ok()
    }
}

struct ConfirmChangeMassiveDirectDebitsUseCaseInput {
    let originAccount: Account
    let signature: SignatureWithToken
}
