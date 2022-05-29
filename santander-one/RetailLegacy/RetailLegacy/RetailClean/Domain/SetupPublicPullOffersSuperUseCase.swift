import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class SetupPublicPullOffersSuperUseCase<Delegate: SuperUseCaseDelegate>: SuperUseCase<Delegate, GenericPresenterErrorHandler> {
    
    override func setupUseCases() {
        add(useCaseProvider.getSetupPullOffersUseCase())
        add(useCaseProvider.getLoadPublicPullOffersVarsUseCase())
        add(useCaseProvider.calculateLocationsUseCase(input: CalculateLocationsUseCaseInput()))
    }
}
