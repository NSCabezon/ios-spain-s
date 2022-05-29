import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class CardboardingConfigurationUseCase: UseCase<CardboardingConfigurationUseCaseInput, CardboardingConfigurationUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appConfigProtocol: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfigProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: CardboardingConfigurationUseCaseInput) throws -> UseCaseResponse<CardboardingConfigurationUseCaseOkOutput, StringErrorOutput> {
        let cardBoardingSteps =
            self.appConfigProtocol.getAppConfigListNode(CardBoardingConstants.cardBoardingSteps)?.compactMap({
                CardboardingConfiguration.Step(rawValue: $0)
            }) ?? []
        let configuration = CardboardingConfiguration(card: requestValues.selectedCard)
        configuration.allowSteps = cardBoardingSteps
        return .ok(CardboardingConfigurationUseCaseOkOutput(configuration: configuration))
    }
}

struct CardboardingConfigurationUseCaseInput {
    let selectedCard: CardEntity
}

struct CardboardingConfigurationUseCaseOkOutput {
    let configuration: CardboardingConfiguration
}
