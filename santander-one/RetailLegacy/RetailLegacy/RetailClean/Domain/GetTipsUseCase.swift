import CoreFoundationLib

class GetTipsUseCase: UseCase<Void, GetTipsUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    private let pullOffersInterpreter: PullOffersInterpreter
    
    init(appRepository: AppRepository, pullOffersInterpreter: PullOffersInterpreter) {
        self.appRepository = appRepository
        self.pullOffersInterpreter = pullOffersInterpreter
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetTipsUseCaseOkOutput, StringErrorOutput> {
        guard let tips = try checkRepositoryResponse(appRepository.getTips()) ?? nil else {
            return UseCaseResponse.ok(GetTipsUseCaseOkOutput(tips: nil, offers: nil))
        }
        
        var offers: [Offer] = []
        
        for tip in tips {
            if let offerId = tip.offerId, let dto = pullOffersInterpreter.getOffer(offerId: offerId) {
                offers.append(Offer(offerDTO: dto))
            }
        }
        
        return UseCaseResponse.ok(GetTipsUseCaseOkOutput(tips: tips, offers: offers))
    }
}

struct GetTipsUseCaseOkOutput {
    let tips: [PullOffersConfigTip]?
    let offers: [Offer]?
}
