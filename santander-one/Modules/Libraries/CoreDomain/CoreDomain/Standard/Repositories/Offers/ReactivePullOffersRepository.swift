//
//  ReactivePullOffersRepository.swift
//  CoreDomain
//
//  Created by José Carlos Estela Anguita on 20/12/21.
//

import Foundation
import OpenCombine

public protocol ReactivePullOffersRepository: AnyObject {
    func fetchOfferInfoPublisher(with identifier: String, userId: String) -> AnyPublisher<PullOfferInfoRepresentable, Error>
    func fetchOfferPublisher(for location: PullOfferLocationRepresentable) -> AnyPublisher<String, Error>
    func fetchVisitedLocations() -> AnyPublisher<[String], Never>
    func visitLocation(_ location: String)
    func visitOffer(_ offer: String, userId: String)
    func disableOfferInSession(_ offer: String)
    func fetchSessionDisabledOffers() -> AnyPublisher<[String], Never>
    func setRule(identifier: String, isValid: Bool)
    func isValidRule(identifier: String) -> AnyPublisher<Bool?, Never>
}
