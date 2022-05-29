import CoreFoundationLib
import SANLegacyLibrary

class PullOfferCandidatesUseCase: UseCase<PullOfferCandidatesUseCaseInput, PullOfferCandidatesUseCaseOkOutput, PullOfferCandidatesUseCaseErrorOutput> {
    
    private let pullOffersInterpreter: PullOffersInterpreter
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider

    init(pullOffersInterpreter: PullOffersInterpreter, appRepository: AppRepository, bsanManagersProvider: BSANManagersProvider) {
        self.pullOffersInterpreter = pullOffersInterpreter
        self.bsanManagersProvider = bsanManagersProvider
        self.appRepository = appRepository
    }
    
    override func executeUseCase(requestValues: PullOfferCandidatesUseCaseInput) throws -> UseCaseResponse<PullOfferCandidatesUseCaseOkOutput, PullOfferCandidatesUseCaseErrorOutput> {
        
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
        guard let userId = user else {
            return UseCaseResponse.error(PullOfferCandidatesUseCaseErrorOutput(nil))
        }
        var outputCandidates = [String: Offer]()
        for location in requestValues.locations {
            let locationTag: String = location.stringTag
            if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                outputCandidates[locationTag] = Offer(offerDTO: candidate)
            } else {
                outputCandidates[locationTag] = nil
            }
        }
        return UseCaseResponse.ok(PullOfferCandidatesUseCaseOkOutput(candidates: outputCandidates))
    }
}

struct PullOfferCandidatesUseCaseInput {
    let locations: [PullOfferLocation]
}

struct PullOfferCandidatesUseCaseOkOutput {
    let candidates: [String: Offer]
}

class PullOfferCandidatesUseCaseErrorOutput: StringErrorOutput {
    
}
