import SANLegacyLibrary

public class PullOfferTutorialCandidatesUseCase: UseCase<PullOfferTutorialCandidatesUseCaseInput, PullOfferTutorialCandidatesUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: PullOfferTutorialCandidatesUseCaseInput) throws -> UseCaseResponse<PullOfferTutorialCandidatesUseCaseOkOutput, StringErrorOutput> {
        let pullOffersInterpreter = dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let appRepository = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let user: String? = try {
            let isSessionEnabled = try appRepository.isSessionEnabled().getResponseData() ?? false
            if !isSessionEnabled {
                return "0"
            } else {
                guard let userDataDTO = try? bsanManagersProvider.getBsanPGManager().getGlobalPosition().getResponseData()?.userDataDTO, let userType = userDataDTO.clientPersonType, let userCode = userDataDTO.clientPersonCode else {
                    return nil
                }
                return userType + userCode
            }
            }()
        guard let userId = user else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        var outputCandidates = [PullOfferLocation: OfferEntity]()
        for location in requestValues.locations {
            if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                outputCandidates[location] = OfferEntity(candidate, location: location)
            }
        }
        return UseCaseResponse.ok(PullOfferTutorialCandidatesUseCaseOkOutput(candidates: outputCandidates))
    }
}

public struct PullOfferTutorialCandidatesUseCaseInput {
    public let locations: [PullOfferLocation]
    
    public init(locations: [PullOfferLocation]) {
        self.locations = locations
    }
}

public struct PullOfferTutorialCandidatesUseCaseOkOutput {
    public let candidates: [PullOfferLocation: OfferEntity]
}
