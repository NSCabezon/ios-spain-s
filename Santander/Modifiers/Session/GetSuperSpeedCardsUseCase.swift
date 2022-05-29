import SANLegacyLibrary
import CoreFoundationLib

final class GetSuperSpeedCardsUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let cardsManager = managersProvider.getBsanCardsManager()
    
        let response = try cardsManager.loadCardSuperSpeed(pagination: nil, isNegativeCreditBalanceEnabled: appConfigRepository.getBool("isNegativeCreditBalanceCardSuperSpeed") ?? false)
        
        if response.isSuccess() {
            return UseCaseResponse.ok()
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
    }
}

extension GetSuperSpeedCardsUseCase: RepositoriesResolvable {}
