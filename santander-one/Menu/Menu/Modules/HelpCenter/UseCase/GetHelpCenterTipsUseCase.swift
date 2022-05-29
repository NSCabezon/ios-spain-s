import CoreFoundationLib

final class GetHelpCenterTipsUseCase: UseCase<Void, GetHelpCenterTipsUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetHelpCenterTipsUseCaseOutput, StringErrorOutput> {
        let appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        
        guard let helpCenterTips = try checkRepositoryResponse(appRepository.getHelpCenterTips()) ?? nil else {
            return .error(StringErrorOutput(nil))
        }
        
        helpCenterTips.forEach {
            $0.offer = containtOffer(forTip: $0)
        }
        
        return .ok(GetHelpCenterTipsUseCaseOutput(helpCenterTips: helpCenterTips))
    }
    
    private func containtOffer(forTip tip: PullOfferTipEntity) -> OfferEntity? {
        let pullOfferInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        guard let offerId = tip.offerId, let offerDTO = pullOfferInterpreter.getOffer(offerId: offerId) else {
            return nil
        }
        return OfferEntity(offerDTO)
    }
}

struct GetHelpCenterTipsUseCaseOutput {
    let helpCenterTips: [PullOfferTipEntity]?
}
