import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class LoadCardDetailUseCase: UseCase<LoadCardDetailUseCaseInput, Void, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: LoadCardDetailUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let bsanCardsManager = managersProvider.getBsanCardsManager()
        
        let cardBSANResponse = try bsanCardsManager.loadCardDetail(cardDTO: requestValues.card)
        if cardBSANResponse.isSuccess() {
            return UseCaseResponse.ok()
        }
        return UseCaseResponse.error(StringErrorOutput(try cardBSANResponse.getErrorMessage()))
    }
}

extension LoadCardDetailUseCase: RepositoriesResolvable {}

struct LoadCardDetailUseCaseInput {
    let card: CardDTO
}
