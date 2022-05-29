import CoreFoundationLib

final class LogoutDialogUseCase: UseCase<Void, LogoutDialogUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LogoutDialogUseCaseOkOutput, StringErrorOutput> {
        let pullOffersInterpreter = dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        
        guard let userId = globalPosition.userId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        var offer: Offer?
        
        // Let's check if the logout location has an offer.
        if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: .LOGOUT_DIALOG) {
            offer = Offer(offerDTO: candidate)
        }
        
        guard offer == nil else {
            return .ok(LogoutDialogUseCaseOkOutput(offer: offer, isLogoutLocation: true))
        }
        
        // If not, let's check on offers array from app_config.
        let appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        var offersArray = appConfigRepository.getAppConfigListNode(DomainConstant.appConfigLogoutOffersRandom) ?? []
        
        var found = false
        for _ in 0 ..< offersArray.count where !found {
            let randomIndex = Int.random(in: 0..<offersArray.endIndex)
            let offerId = offersArray[randomIndex]
            if let validOffer = pullOffersInterpreter.getValidOffer(offerId: offerId) {
                found = true
                offer = Offer(offerDTO: validOffer)
            } else {
                offersArray.remove(at: randomIndex)
            }
        }
        
        return .ok(LogoutDialogUseCaseOkOutput(offer: offer, isLogoutLocation: false))
    }
}

struct LogoutDialogUseCaseOkOutput {
    let offer: Offer?
    let isLogoutLocation: Bool
}
