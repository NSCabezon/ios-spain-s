import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmBlockCardUseCase: ConfirmUseCase<ConfirmBlockCardUseCaseInput, ConfirmBlockCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmBlockCardUseCaseInput) throws -> UseCaseResponse<ConfirmBlockCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let cardDTO = requestValues.blockCard.cardDTO
        let signatureDTO = requestValues.signature.dto
        let blockCardStatus = requestValues.blockCardStatus
        
        let response = try provider.getBsanCardsManager().confirmBlockCard(cardDTO: cardDTO, signatureDTO: signatureDTO, blockText: requestValues.blockText, cardBlockType: blockCardStatus.getCardBlockType)
        
        if response.isSuccess(), let blockCardConfirmDTO = try response.getResponseData() {
            return UseCaseResponse.ok(ConfirmBlockCardUseCaseOkOutput(blockCardConfirm: BlockCardConfirm.create(blockCardConfirmDTO)))
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmBlockCardUseCaseInput {
    let blockCard: BlockCardDetail
    let blockCardStatus: BlockCardStatusType
    let blockText: String
    let signature: Signature
}

struct ConfirmBlockCardUseCaseOkOutput {
    let blockCardConfirm: BlockCardConfirm
}
