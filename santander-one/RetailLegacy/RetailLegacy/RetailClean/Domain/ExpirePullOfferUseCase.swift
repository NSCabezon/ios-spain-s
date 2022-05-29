import SANLegacyLibrary
import CoreFoundationLib

class ExpirePullOfferUseCase: UseCase<ExpirePullOfferUseCaseInput, Void, StringErrorOutput> {
    
    private let appRepository: AppRepository
    private let pullOffersInterpreter: PullOffersInterpreter
    private let bsanManagersProvider: BSANManagersProvider
    
    init(appRepository: AppRepository, pullOffersInterpreter: PullOffersInterpreter, bsanManagersProvider: BSANManagersProvider) {
        self.appRepository = appRepository
        self.pullOffersInterpreter = pullOffersInterpreter
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: ExpirePullOfferUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let user: String? = try {
            let isSessionEnabled = try appRepository.isSessionEnabled().getResponseData() ?? false
            if !isSessionEnabled {
                return "0"
            } else {
                guard let dto = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition()) else {
                    return nil
                }
                let gp = GlobalPosition.createFrom(dto: dto)
                return gp.userId
            }
        }()
        
        guard let userId = user, let offerId = requestValues.offerId, let offer = pullOffersInterpreter.getOffer(offerId: offerId) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        pullOffersInterpreter.expireOffer(userId: userId, offerDTO: offer)
        
        return UseCaseResponse.ok()
    }
}

struct ExpirePullOfferUseCaseInput {
    let offerId: String?
}
