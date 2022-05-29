//
//  MockPullOffersRepository.swift
//  CoreTestData
//
//  Created by José Carlos Estela Anguita on 22/12/21.
//

import Foundation
import CoreDomain
import OpenCombine

open class MockPullOffersRespository: ReactivePullOffersRepository {
    
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    open func fetchOfferInfoPublisher(with identifier: String, userId: String) -> AnyPublisher<PullOfferInfoRepresentable, Error> {
        return mockDataInjector.mockDataProvider.reactivePullOffers.fetchOfferInfoPublisher
    }
    
    open func fetchOfferPublisher(for location: PullOfferLocationRepresentable) -> AnyPublisher<String, Error> {
        return mockDataInjector.mockDataProvider.reactivePullOffers.fetchOfferPublisher
    }
    
    open func fetchVisitedLocations() -> AnyPublisher<[String], Never> {
        return mockDataInjector.mockDataProvider.reactivePullOffers.fetchVisitedLocations
    }
    
    open func visitLocation(_ location: String) {
        
    }
    
    open func visitOffer(_ offer: String, userId: String) {
        
    }
    
    open func disableOfferInSession(_ offer: String) {
        
    }
    
    open func fetchSessionDisabledOffers() -> AnyPublisher<[String], Never> {
        return mockDataInjector.mockDataProvider.reactivePullOffers.fetchSessionDisabledOffers
    }
    
    public func setRule(identifier: String, isValid: Bool) {
        
    }
    public func isValidRule(identifier: String) -> AnyPublisher<Bool?, Never> {
        return Just(nil).eraseToAnyPublisher()
    }
}
