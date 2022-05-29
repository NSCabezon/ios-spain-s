//
//  MockOffersRepository.swift
//  CoreTestData
//
//  Created by José Carlos Estela Anguita on 22/12/21.
//

import CoreDomain
import OpenCombine

public struct MockOffersDataProvider {
    public var fetchOffersPublisher: AnyPublisher<[OfferRepresentable], Never> = Just([]).eraseToAnyPublisher()
}
