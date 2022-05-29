//
//  DefaultPullOffersConfigRepository.swift
//  CoreFoundationLib
//
//  Created by alvola on 2/2/22.
//

import Foundation
import OpenCombine
import CoreDomain
import MapKit

public final class DefaultPullOffersConfigRepository {
    public let pullOffersConfigRepository: PullOffersConfigRepositoryProtocol
    
    public init(pullOffersConfigRepository: PullOffersConfigRepositoryProtocol) {
        self.pullOffersConfigRepository = pullOffersConfigRepository
    }
}

extension DefaultPullOffersConfigRepository: ReactivePullOffersConfigRepository {
    public func getPublicCarouselOffers() -> AnyPublisher<[PullOfferTipRepresentable], Never> {
        let offers = pullOffersConfigRepository.getPublicCarouselOffers()
        return Just(offers).eraseToAnyPublisher()
    }
}
