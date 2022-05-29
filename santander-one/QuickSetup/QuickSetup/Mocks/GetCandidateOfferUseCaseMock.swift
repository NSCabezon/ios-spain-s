import CoreFoundationLib
import CoreTestData
import OpenCombine
import CoreDomain

public struct GetCandidateOfferUseCaseMock {
    private let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
}

extension GetCandidateOfferUseCaseMock: GetCandidateOfferUseCase {
    public func fetchCandidateOfferPublisher(location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable, Error> {
        mockDataInjector.mockDataProvider.reactiveOffers.fetchOffersPublisher
            .setFailureType(to: Error.self)
            .compactMap { offers in
                return offers.first(where: { location.stringTag == $0.pullOfferLocation?.stringTag })
            }
            .eraseToAnyPublisher()
    }
}
