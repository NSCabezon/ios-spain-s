import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class ConfirmActivateCardUseCase: ConfirmUseCase<ConfirmActivateCardUseCaseInput, ConfirmActivateCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmActivateCardUseCaseInput) throws -> UseCaseResponse<ConfirmActivateCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let signatureResponse = try provider.getBsanCardsManager().confirmActivateCard(cardDTO: requestValues.card.cardDTO, expirationDate: requestValues.expirationDate, signatureDTO: requestValues.signature.dto)
        
        if !signatureResponse.isSuccess() {
            let signatureType = try getSignatureResult(signatureResponse)
            let errorMessage = try signatureResponse.getErrorMessage()
            let errorCode = try signatureResponse.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorMessage, signatureType, errorCode))
        } else {
            let error = try signatureResponse.getResponseData()
            return UseCaseResponse.ok(ConfirmActivateCardUseCaseOkOutput(errorDesc: error))
        }
    }
}

struct ConfirmActivateCardUseCaseInput {
    let signature: Signature
    let card: Card
    let expirationDate: Date
}

struct ConfirmActivateCardUseCaseOkOutput {
    let errorDesc: String?
}
