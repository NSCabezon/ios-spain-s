import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetValidPullOfferUseCase: UseCase<GetValidPullOfferUseCaseInput, GetValidPullOfferUseCaseOkOutput, StringErrorOutput> {
    
    private let pullOffersInterpreter: PullOffersInterpreter
    
    init(pullOffersInterpreter: PullOffersInterpreter) {
        self.pullOffersInterpreter = pullOffersInterpreter
    }
    
    override func executeUseCase(requestValues: GetValidPullOfferUseCaseInput) throws -> UseCaseResponse<GetValidPullOfferUseCaseOkOutput, StringErrorOutput> {
        guard let offerDTO = pullOffersInterpreter.getValidOffer(offerId: requestValues.offerId) else {
            return UseCaseResponse.error(StringErrorOutput("alert_label_notFindOffer"))
        }
        return UseCaseResponse.ok(GetValidPullOfferUseCaseOkOutput(offer: Offer(offerDTO: offerDTO)))
    }
}

struct GetValidPullOfferUseCaseInput {
    let offerId: String
}

struct GetValidPullOfferUseCaseOkOutput {
    let offer: Offer
}
