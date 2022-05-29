import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class SetupActivateCardUseCase: SetupUseCase<SetupActivateCardUseCaseInput, SetupActivateCardUseCaseOkOutput, SetupActivateCardUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupActivateCardUseCaseInput) throws -> UseCaseResponse<SetupActivateCardUseCaseOkOutput, SetupActivateCardUseCaseErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        let cardsManager = provider.getBsanCardsManager()
        
        let cardDto = requestValues.card.cardDTO
        
        let cardDetailDto = try getCardDetailDTO(cardDto: cardDto)
        
        guard let expirationDate = cardDetailDto?.expirationDate else {
            return UseCaseResponse.error(SetupActivateCardUseCaseErrorOutput(nil))
        }
        
        let response = try cardsManager.activateCard(cardDTO: cardDto, expirationDate: expirationDate)
        
        if response.isSuccess(), let activateCardDto = try response.getResponseData() {
            return UseCaseResponse.ok(SetupActivateCardUseCaseOkOutput(activateCard: ActivateCard(dto: activateCardDto), expirationDate: expirationDate, operativeConfig: operativeConfig))
        }
        return UseCaseResponse.error(SetupActivateCardUseCaseErrorOutput(try response.getErrorMessage() ?? ""))
    }

    private func getCardDetailDTO(cardDto: CardDTO) throws -> CardDetailDTO? {
        let cardsManager = provider.getBsanCardsManager()
        let response = try cardsManager.getCardDetail(cardDTO: cardDto)
        
        return try response.getResponseData()
    }
}

struct SetupActivateCardUseCaseInput {
    let card: Card
}

struct SetupActivateCardUseCaseOkOutput {
    let activateCard: ActivateCard
    let expirationDate: Date
    var operativeConfig: OperativeConfig
}

extension SetupActivateCardUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}

class SetupActivateCardUseCaseErrorOutput: StringErrorOutput {
    
}
