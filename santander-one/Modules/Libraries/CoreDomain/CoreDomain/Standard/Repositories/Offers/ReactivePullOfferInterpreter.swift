import Foundation
import OpenCombine

public protocol ReactivePullOffersInterpreter {
    func getValidOffer(offerId: String) -> AnyPublisher<OfferRepresentable, Error>
}
