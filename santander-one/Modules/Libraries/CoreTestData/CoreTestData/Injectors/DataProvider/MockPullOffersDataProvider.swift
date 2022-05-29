//
//  MockPullOffersRespository.swift
//  CoreTestData
//
//  Created by José Carlos Estela Anguita on 22/12/21.
//

import CoreDomain
import OpenCombine
import CoreFoundationLib

public struct MockPullOffersDataProvider {
    public var fetchOfferInfoPublisher: AnyPublisher<PullOfferInfoRepresentable, Error> = Fail(error: RepositoryError.unknown).eraseToAnyPublisher()
    public var fetchOfferPublisher: AnyPublisher<String, Error> = Fail(error: RepositoryError.unknown).eraseToAnyPublisher()
    public var fetchVisitedLocations: AnyPublisher<[String], Never> = Just([]).eraseToAnyPublisher()
    public var fetchSessionDisabledOffers: AnyPublisher<[String], Never> = Just([]).eraseToAnyPublisher()
}
