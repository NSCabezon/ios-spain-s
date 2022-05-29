//
//  MockOffersRepository.swift
//  CoreTestData
//
//  Created by José Carlos Estela Anguita on 22/12/21.
//

import CoreDomain
import OpenCombine

public final class MockOffersRepository: ReactiveOffersRepository {
    
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func fetchOffersPublisher() -> AnyPublisher<[OfferRepresentable], Never> {
        return mockDataInjector.mockDataProvider.reactiveOffers.fetchOffersPublisher
    }
}
