import CoreFoundationLib
import SANLegacyLibrary

final class LoadHomeTipsUseCase: UseCase<Void, LoadHomeTipsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadHomeTipsUseCaseOkOutput, StringErrorOutput> {
        let pullOffersConfigRepository = dependenciesResolver.resolve(for: PullOffersConfigRepositoryProtocol.self)
        guard let homeTips = pullOffersConfigRepository.getHomeTips() else {
            return .error(StringErrorOutput(nil))
        }
        let entity = self.getValidOffers(homeTips)
        return .ok(LoadHomeTipsUseCaseOkOutput(homeTips: entity))
    }
    
    func getValidOffers(_ homeTips: [PullOffersHomeTipsDTO]) -> [PullOffersHomeTipsEntity] {
        let pullOffersInterpreter = dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        var arrayTips: [PullOffersHomeTipsEntity] = []
        homeTips.forEach { (homeTip) in
            guard let content = homeTip.content else { return }
            let contents = content.compactMap { (dto) -> PullOffersHomeTipsContentDTO? in
                guard let offerId = dto.offerId,
                    pullOffersInterpreter.getValidOffer(offerId: offerId) != nil
                    else { return nil }
                return dto
            }
            if contents.count > 0 {
                let dto = PullOffersHomeTipsDTO(title: homeTip.title, content: contents)
                arrayTips.append(PullOffersHomeTipsEntity(dto))
            }
        }
        return arrayTips
    }
}

struct LoadHomeTipsUseCaseOkOutput {
    let homeTips: [PullOffersHomeTipsEntity]?
}
