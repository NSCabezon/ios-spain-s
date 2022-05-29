import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class LoadPrepaidCardUseCase: UseCase<LoadPrepaidCardUseCaseInput, Void, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: LoadPrepaidCardUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        
        let cardBSANResponse = try managersProvider.getBsanCardsManager().loadPrepaidCardData(cardDTO: requestValues.card)
        if cardBSANResponse.isSuccess() {
            return UseCaseResponse.ok()
        }
        return UseCaseResponse.error(StringErrorOutput(try cardBSANResponse.getErrorMessage()))
    }
    
}

struct LoadPrepaidCardUseCaseInput {
    let card: CardDTO
}

extension LoadPrepaidCardUseCase: RepositoriesResolvable {}
