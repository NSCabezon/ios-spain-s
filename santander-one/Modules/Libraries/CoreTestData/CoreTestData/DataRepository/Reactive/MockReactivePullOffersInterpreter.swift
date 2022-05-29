import Foundation
import CoreDomain
import OpenCombine

public final class MockReactivePullOffersInterpreter: ReactivePullOffersInterpreter {
    
    private let offersPublisher: AnyPublisher<[OfferRepresentable], Never>
    
    public init(mockDataInjector: MockDataInjector) {
        offersPublisher = mockDataInjector.mockDataProvider.reactiveOffers.fetchOffersPublisher
    }
    
    public func getValidOffer(offerId: String) -> AnyPublisher<OfferRepresentable, Error> {
        return offersPublisher
            .flatMap { offers -> AnyPublisher<OfferRepresentable, Error> in
            guard let firstOffer = offers.first else { return Fail(error: NSError(description: "error")).eraseToAnyPublisher() }
            return Just(firstOffer)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
            .eraseToAnyPublisher()
    }
}
