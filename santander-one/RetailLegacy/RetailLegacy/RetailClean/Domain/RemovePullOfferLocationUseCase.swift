import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class RemovePullOfferLocationUseCase: UseCase<RemovePullOfferLocationUseCaseInput, Void, StringErrorOutput> {
    
    private let pullOffersInterpreter: PullOffersInterpreter
    
    init(pullOffersInterpreter: PullOffersInterpreter) {
        self.pullOffersInterpreter = pullOffersInterpreter
    }
    
    override func executeUseCase(requestValues: RemovePullOfferLocationUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        pullOffersInterpreter.removeOffer(location: requestValues.location)
        return .ok()
    }
}

struct RemovePullOfferLocationUseCaseInput {
    let location: String
}
