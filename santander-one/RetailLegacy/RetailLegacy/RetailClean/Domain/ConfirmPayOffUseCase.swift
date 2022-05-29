import SANLegacyLibrary
import CoreFoundationLib

final class ConfirmPayOffUseCase: ConfirmUseCase<ConfirmPayOffUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmPayOffUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let cardDTO = requestValues.card.cardDTO
        let cardDetailDTO = try checkRepositoryResponse(provider.getBsanCardsManager().getCardDetail(cardDTO: cardDTO))
        let amountDTO = requestValues.amount.amountDTO
        let signatureDTO = requestValues.signatureWithToken.signature.dto
        let signatureToken = requestValues.signatureWithToken.magicPhrase
        let signatureTokenDTO = SignatureWithTokenDTO(signatureDTO: signatureDTO, magicPhrase: signatureToken)
        
        if let cardDetail = cardDetailDTO {
            let response = try provider.getBsanCardsManager().confirmPayOff(cardDTO: cardDTO, cardDetailDTO: cardDetail, amountDTO: amountDTO, signatureWithTokenDTO: signatureTokenDTO)
            
            guard response.isSuccess() else {
                let signatureType = try getSignatureResult(response)
                let errorDescription = try response.getErrorMessage() ?? ""
                let errorCode = try response.getErrorCode()
                return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
            }
            return UseCaseResponse.ok()
        }
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput("", .otherError, nil))
    }
}

struct ConfirmPayOffUseCaseInput {
    let card: Card
    let cardDetail: CardDetail
    let amount: Amount
    let signatureWithToken: SignatureWithToken
}
