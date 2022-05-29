import Foundation
import OpenCombine

public protocol ReactivePullOffersConfigRepository {
    func getPublicCarouselOffers() -> AnyPublisher<[PullOfferTipRepresentable], Never>
}
