import CoreFoundationLib
import SANLegacyLibrary

class PullOfferTutorialCandidatesUseCase: UseCase<PullOfferTutorialCandidatesUseCaseInput, PullOfferTutorialCandidatesUseCaseOkOutput, PullOfferTutorialCandidatesUseCaseErrorOutput> {
    
    private let pullOffersInterpreter: PullOffersInterpreter
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    
    init(pullOffersInterpreter: PullOffersInterpreter, appRepository: AppRepository, bsanManagersProvider: BSANManagersProvider) {
        self.pullOffersInterpreter = pullOffersInterpreter
        self.bsanManagersProvider = bsanManagersProvider
        self.appRepository = appRepository
    }
    
    override func executeUseCase(requestValues: PullOfferTutorialCandidatesUseCaseInput) throws -> UseCaseResponse<PullOfferTutorialCandidatesUseCaseOkOutput, PullOfferTutorialCandidatesUseCaseErrorOutput> {
        
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
            return .error(PullOfferTutorialCandidatesUseCaseErrorOutput(nil))
        }
        
        var outputCandidates: [String: Offer] = [:]
        if let locationTutorial = requestValues.locationTutorial,
            !pullOffersInterpreter.isLocationVisitedInSession(location: locationTutorial) {
            outputCandidates[locationTutorial.stringTag] = getOutputCandidates(location: locationTutorial, userId: userId)
        }
        
        return .ok(PullOfferTutorialCandidatesUseCaseOkOutput(candidates: outputCandidates))
    }
    
    private func getOutputCandidates(location: PullOfferLocation, userId: String) -> Offer? {
        if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
            return Offer(offerDTO: candidate)
        } else {
            return nil
        }
    }
}

struct PullOfferTutorialCandidatesUseCaseInput {
    let locationTutorial: PullOfferLocation?
}

struct PullOfferTutorialCandidatesUseCaseOkOutput {
    let candidates: [String: Offer]
}

class PullOfferTutorialCandidatesUseCaseErrorOutput: StringErrorOutput {
    
}
