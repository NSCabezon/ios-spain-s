//
//  GetAnalysisAreaOffersUseCase.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 21/3/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public typealias AnalysisAreaCandidateOffer = (offer: OfferRepresentable, location: PullOfferLocationRepresentable)

public protocol GetAnalysisAreaOffersUseCase {
    func fetchCandidateOffersPublisher(_ locations: [PullOfferLocationRepresentable]) -> AnyPublisher<[AnalysisAreaCandidateOffer], Never>
}

struct DefaultGetAnalysisAreaOffersUseCase {
    let offersUseCase: GetCandidateOfferUseCase
    
    init(dependencies: AnalysisAreaHomeDependenciesResolver) {
        self.offersUseCase = dependencies.external.resolve()
    }
}

extension DefaultGetAnalysisAreaOffersUseCase: GetAnalysisAreaOffersUseCase {
    func fetchCandidateOffersPublisher(_ locations: [PullOfferLocationRepresentable]) -> AnyPublisher<[AnalysisAreaCandidateOffer], Never> {
        let validOffersPublishers = locations.compactMap { location -> AnyPublisher<AnalysisAreaCandidateOffer, Never> in
            return offersUseCase.fetchCandidateOfferPublisher(location: location)
                .catch { _ in
                    return Just(EmptyOffer()).eraseToAnyPublisher()
                }
                .map { result in
                    var candidateOffer: AnalysisAreaCandidateOffer
                    candidateOffer.offer = result
                    candidateOffer.location = location
                    return candidateOffer
                }.eraseToAnyPublisher()
        }
        return Publishers
            .MergeMany(validOffersPublishers)
            .collect(locations.count)
            .eraseToAnyPublisher()
    }
}

struct EmptyOffer: OfferRepresentable {
    var pullOfferLocation: PullOfferLocationRepresentable?
    var bannerRepresentable: BannerRepresentable?
    var action: OfferActionRepresentable?
    var id: String?
    var identifier: String = ""
    var transparentClosure: Bool = false
    var productDescription: String = ""
    var rulesIds: [String] = []
    var startDateUTC: Date?
    var endDateUTC: Date?
}
