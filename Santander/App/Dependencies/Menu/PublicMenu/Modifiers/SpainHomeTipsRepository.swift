import Foundation
import CoreFoundationLib
import OpenCombine

final class SpainHomeTipsRepository: HomeTipsRepository {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func getHomeTipsCount() -> AnyPublisher<Int, Never> {
        let pullOffersConfigRepository = dependenciesResolver.resolve(for: PullOffersConfigRepositoryProtocol.self)
        guard let homeTips = pullOffersConfigRepository.getHomeTips() else {
            return Empty().eraseToAnyPublisher()
        }
        let validHomeTips = self.getValidOffers(homeTips)
        return Just(validHomeTips).eraseToAnyPublisher()
    }
}

private extension SpainHomeTipsRepository {
    func getValidOffers(_ homeTips: [PullOffersHomeTipsDTO]) -> Int {
        let pullOffersInterpreter = dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        return homeTips.reduce(0) { total, next  in
            guard let content = next.content else { return total }
            let contents = content.compactMap { (dto) -> PullOffersHomeTipsContentDTO? in
                guard let offerId = dto.offerId,
                    pullOffersInterpreter.getValidOffer(offerId: offerId) != nil
                    else { return nil }
                return dto
            }
            return total + contents.count
        }
    }
}
