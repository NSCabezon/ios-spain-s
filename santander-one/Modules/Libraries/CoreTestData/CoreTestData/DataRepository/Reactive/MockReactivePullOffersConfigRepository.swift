import Foundation
import CoreDomain
import OpenCombine

public final class MockReactivePullOffersConfigRepository: ReactivePullOffersConfigRepository {
    public init() {}
    
    public func getPublicCarouselOffers() -> AnyPublisher<[PullOfferTipRepresentable], Never> {
        return Just([]).eraseToAnyPublisher()
    }
}
