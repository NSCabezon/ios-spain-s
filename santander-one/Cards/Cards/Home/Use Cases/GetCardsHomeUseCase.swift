import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetCardsHomeUseCase: UseCase<Void, GetCardsHomeUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCardsHomeUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let configuration: CardsHomeConfiguration = self.dependenciesResolver.resolve(for: CardsHomeConfiguration.self)
        let cards: [CardEntity] = globalPosition.cards.visibles()
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let isEnabledMap = appConfigRepository.getBool("enableCardTransactionsMap") == true
        let isPBuser = globalPosition.isPb
        let isEasyPaymentEnabled = appConfigRepository.getBool("enableEasyPayCards") == true
        let isCrossSellingEnabled = appConfigRepository.getBool("enableCardMovementsCrossSelling") == true
        let cardsCrossSelling = appConfigRepository.getAppConfigListNode(
            "listCardMovementsCrossSelling",
            object: CardsMovementsCrossSellingEntity.self,
            options: .json5Allowed) ?? []
        let cardsCrossSellingProperties = cardsCrossSelling
            .map(CardsMovementsCrossSellingProperties.init)
        return UseCaseResponse.ok(
            GetCardsHomeUseCaseOkOutput(
                cards: cards,
                configuration: configuration,
                isEnabledMap: isEnabledMap,
                isPBUser: isPBuser ?? false,
                isEasyPaymentEnabled: isEasyPaymentEnabled,
                isCrossSellingEnabled: isCrossSellingEnabled,
                cardsCrossSelling: cardsCrossSellingProperties
            ))
    }
}

struct GetCardsHomeUseCaseOkOutput {
    let cards: [CardEntity]
    let configuration: CardsHomeConfiguration
    let isEnabledMap: Bool
    let isPBUser: Bool
    let isEasyPaymentEnabled: Bool
    let isCrossSellingEnabled: Bool
    let cardsCrossSelling: [CardsMovementsCrossSellingProperties]
}
