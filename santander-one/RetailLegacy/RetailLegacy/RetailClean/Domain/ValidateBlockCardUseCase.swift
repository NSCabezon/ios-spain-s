import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateBlockCardUseCase: UseCase<ValidateBlockCardUseCaseInput, ValidateBlockCardUseCaseOkOutput, ValidateBlockCardUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateBlockCardUseCaseInput) throws -> UseCaseResponse<ValidateBlockCardUseCaseOkOutput, ValidateBlockCardUseCaseErrorOutput> {        
        let cardDTO = requestValues.blockCard.cardDTO
        let blockCardStatus = requestValues.blockCardStatus
        
        let response = try provider.getBsanCardsManager().blockCard(cardDTO: cardDTO, blockText: requestValues.blockText, cardBlockType: blockCardStatus.getCardBlockType)
        
        if response.isSuccess(), let blockCardDTO = try response.getResponseData() {
            return UseCaseResponse.ok(ValidateBlockCardUseCaseOkOutput(blockCard: BlockCard.create(blockCardDTO)))
        }
        return UseCaseResponse.error(ValidateBlockCardUseCaseErrorOutput(try response.getErrorMessage()))
    }
}

struct ValidateBlockCardUseCaseInput {
    let blockCard: BlockCardDetail
    let blockCardStatus: BlockCardStatusType
    let blockText: String
}

struct ValidateBlockCardUseCaseOkOutput {
    let blockCard: BlockCard
}

class ValidateBlockCardUseCaseErrorOutput: StringErrorOutput {
}
