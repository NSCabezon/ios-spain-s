import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class LoadInactiveCardsTempUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let BSANResponse = try managersProvider.getBsanCardsManager().loadInactiveCards(inactiveCardType: InactiveCardType.temporallyOff)
        if BSANResponse.isSuccess() {
            return UseCaseResponse.ok()
        }
        return UseCaseResponse.error(StringErrorOutput(try BSANResponse.getErrorMessage()))
    }
}

extension LoadInactiveCardsTempUseCase: RepositoriesResolvable {}
