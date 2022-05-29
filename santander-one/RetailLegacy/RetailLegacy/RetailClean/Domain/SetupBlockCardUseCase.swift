import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class SetupBlockCardUseCase: SetupUseCase<SetupBlockCardUseCaseInput, SetupBlockCardUseCaseOkOutput, SetupBlockCardUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupBlockCardUseCaseInput) throws -> UseCaseResponse<SetupBlockCardUseCaseOkOutput, SetupBlockCardUseCaseErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let cardDTO = requestValues.card.cardDTO
        return UseCaseResponse.ok(SetupBlockCardUseCaseOkOutput(blockCard: BlockCardDetail.create(cardDTO, card: requestValues.card), operativeConfig: operativeConfig))
    }
}

struct SetupBlockCardUseCaseInput {
    let card: Card
}

struct SetupBlockCardUseCaseOkOutput {
    let blockCard: BlockCardDetail
    var operativeConfig: OperativeConfig
}

extension SetupBlockCardUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}

class SetupBlockCardUseCaseErrorOutput: StringErrorOutput {
}
