//
//  GetCandidateOfferUseCase.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 20/12/21.
//

import Foundation
import OpenCombine
import CoreDomain
import RxCombine
import OpenCombineDispatch

public protocol GetCandidateOfferUseCase {
    func fetchCandidateOfferPublisher(location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable, Error>
}

public struct DefaultGetCandidateOfferUseCase {
    private let dependenciesResolver: OffersDependenciesResolver
    
    public init(dependenciesResolver: OffersDependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension DefaultGetCandidateOfferUseCase: GetCandidateOfferUseCase {
    public func fetchCandidateOfferPublisher(location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable, Error> {
        return Publishers.Zip4(
            pullOffersRepository.fetchOfferPublisher(for: location),
            pullOffersRepository.fetchSessionDisabledOffers().mapError({ _ in RepositoryError.unknown }),
            offersRepository.fetchOffersPublisher().mapError({ _ in RepositoryError.unknown }),
            getUserIdPublisher()
        )
        .subscribe(on: DispatchQueue.global().ocombine)
        .flatMap(checkCandidate)
        .handleEvents(receiveOutput: { response in
            pullOffersRepository.visitLocation(location.stringTag)
            pullOffersRepository.visitOffer(response.offer.identifier, userId: response.userId)
            trackCandidate(screenId: location.pageForMetrics, extraParameters: ["location": location.stringTag, "offerId": response.offer.identifier])
        })
        .map(\.offer)
        .eraseToAnyPublisher()
    }
}

private extension DefaultGetCandidateOfferUseCase {
    var pullOffersRepository: ReactivePullOffersRepository {
        return dependenciesResolver.resolve()
    }
    var offersRepository: ReactiveOffersRepository {
        return dependenciesResolver.resolve()
    }
    var rulesRepository: ReactiveRulesRepository {
        return dependenciesResolver.resolve()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve()
    }
}

private extension DefaultGetCandidateOfferUseCase {
    
    typealias OfferWithUserId = (offer: OfferRepresentable, userId: String)
    
    func getUserIdPublisher() -> AnyPublisher<String, Error> {
        let repository: GlobalPositionDataRepository = dependenciesResolver.resolve()
        return repository.getGlobalPosition()
            .map(\.userId)
            .flatMap { userId -> AnyPublisher<String, Error> in
                guard let userId = userId else { return Fail(error: NSError(description: "no-user-id")).eraseToAnyPublisher() }
                return Just(userId).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func checkCandidate(_ offer: String, disabledOffers: [String], offers: [OfferRepresentable], userId: String) -> AnyPublisher<OfferWithUserId, Error> {
        guard
            !disabledOffers.contains(offer),
            let foundOffer = offers.first(where: { $0.identifier == offer })
        else {
            return Fail(error: NSError(description: "no-offer")).eraseToAnyPublisher()
        }
        let response = OfferWithUserId(offer: foundOffer, userId: userId)
        return Just(response).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func trackCandidate(screenId: String?, extraParameters: [String: String]) {
        guard let screenId: String = screenId else { return }
        trackerManager.trackEvent(screenId: screenId, eventId: "oferta_visualizacion", extraParameters: extraParameters)
    }
}
