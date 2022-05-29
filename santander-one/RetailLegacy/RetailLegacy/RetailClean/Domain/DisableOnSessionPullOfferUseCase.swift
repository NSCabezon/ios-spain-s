import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class DisableOnSessionPullOfferUseCase: UseCase<DisableOnSessionPullOfferUseCaseInput, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: DisableOnSessionPullOfferUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let pullOffersInterpreter = dependenciesResolver.resolve(for: PullOffersInterpreter.self)

        guard let offerId = requestValues.offerId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }

        pullOffersInterpreter.disableOffer(identifier: offerId)
        return .ok()
    }
}

struct DisableOnSessionPullOfferUseCaseInput {
    let offerId: String?
}
