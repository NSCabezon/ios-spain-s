import CoreFoundationLib
import CoreDomain

class GetPullOfferActionUseCase: UseCase<GetPullOfferActionUseCaseInput, GetPullOfferActionUseCaseOkOutput, StringErrorOutput> {
    
    private let pullOffersInterpreter: PullOffersInterpreter
    
    init(pullOffersInterpreter: PullOffersInterpreter) {
        self.pullOffersInterpreter = pullOffersInterpreter
    }
    
    override func executeUseCase(requestValues: GetPullOfferActionUseCaseInput) throws -> UseCaseResponse<GetPullOfferActionUseCaseOkOutput, StringErrorOutput> {
        let offerDTO = pullOffersInterpreter.getOffer(offerId: requestValues.offerId)
        return UseCaseResponse.ok(GetPullOfferActionUseCaseOkOutput(offerAction: offerDTO?.product.action))
    }
}

struct GetPullOfferActionUseCaseInput {
    let offerId: String
}

struct GetPullOfferActionUseCaseOkOutput {
    let offerAction: OfferActionRepresentable?
}
