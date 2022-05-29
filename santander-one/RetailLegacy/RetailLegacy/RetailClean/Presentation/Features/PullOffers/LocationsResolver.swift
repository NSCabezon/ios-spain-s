import CoreFoundationLib

protocol LocationsResolver {
    var useCaseProvider: UseCaseProvider { get }
    var useCaseHandler: UseCaseHandler { get }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
    
    var locations: [PullOfferLocation] { get }
    var locationTutorial: PullOfferLocation? { get }
}

extension LocationsResolver {
    var locations: [PullOfferLocation] {
        return []
    }
    var locationTutorial: PullOfferLocation? {
        return nil
    }
    
    func getCandidateOffers(completion: @escaping ([PullOfferLocation: Offer]) -> Void) {
        let locations = self.locations
        let useCase = useCaseProvider.getCandidatesUseCase(input: PullOfferCandidatesUseCaseInput(locations: locations))
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            var candidates = [PullOfferLocation: Offer]()
            locations.forEach { candidates[$0] = result.candidates[$0.stringTag] }
            completion(candidates)
        })
    }
    
    func getCandidateTutorialsOffers(completion: @escaping ([PullOfferLocation: Offer]) -> Void) {
        let locationTutorial = self.locationTutorial
        let useCase = useCaseProvider.getTutorialCandidatesUseCase(input: PullOfferTutorialCandidatesUseCaseInput(locationTutorial: locationTutorial))
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            guard let location = locationTutorial else { return }
            var candidates: [PullOfferLocation: Offer] = [:]
            candidates[location] = result.candidates[location.stringTag]
            completion(candidates)
        })
    }
}
