//
//  MockReactivePullOffersRepository.swift
//  CoreTestData
//
//  Created by alvola on 20/4/22.
//

import Foundation
import CoreDomain
import OpenCombine

public final class MockReactivePullOffersRepository: ReactivePullOffersRepository {
    public init() {}
    public func fetchOfferInfoPublisher(with identifier: String, userId: String) -> AnyPublisher<PullOfferInfoRepresentable, Error> {
        return Just(PullOfferInfoMock()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    public func fetchOfferPublisher(for location: PullOfferLocationRepresentable) -> AnyPublisher<String, Error> {
        return Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    public func fetchVisitedLocations() -> AnyPublisher<[String], Never> {
        return Just([""]).eraseToAnyPublisher()
    }
    
    public func visitLocation(_ location: String) { }
    
    public func visitOffer(_ offer: String, userId: String) { }
    
    public func disableOfferInSession(_ offer: String) { }
    
    public func fetchSessionDisabledOffers() -> AnyPublisher<[String], Never> {
        return Just([""]).eraseToAnyPublisher()
    }
    
    public func setRule(identifier: String, isValid: Bool) { }
    
    public func isValidRule(identifier: String) -> AnyPublisher<Bool?, Never> {
        return Just(true).eraseToAnyPublisher()
    }
}

private extension MockReactivePullOffersRepository {
    struct PullOfferInfoMock: PullOfferInfoRepresentable { }
}
