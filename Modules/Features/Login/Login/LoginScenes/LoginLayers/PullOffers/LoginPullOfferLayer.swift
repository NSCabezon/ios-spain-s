//
//  LoginPullOfferLayer.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/25/20.
//

import Foundation
import CoreFoundationLib

protocol LoginPullOfferLayerDelegate: class {
    func loadPullOffersSuccess()
    func didLoadCandidatePullOffers(_ offers: [PullOfferLocation: OfferEntity])
}

final class LoginPullOfferLayer {
    private let dependenciesResolver: DependenciesResolver
    private weak var delegate: LoginPullOfferLayerDelegate?
    private var locations = [PullOfferLocation]()
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    private var trusteerUseCase: TrusteerUseCase {
        return self.dependenciesResolver.resolve(for: TrusteerUseCase.self)
    }
    
    private var pullOfferCandidatesUseCase: PullOfferCandidatesUseCase {
        return self.dependenciesResolver.resolve(for: PullOfferCandidatesUseCase.self)
    }
    
    lazy var loadPullOffersSuperUseCase: SetupPublicPullOffersSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: SetupPublicPullOffersSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func setPullOfferLocations(_ locations: [PullOfferLocation]) {
        self.locations = locations
    }
    
    func setDelegate(_ delegate: LoginPullOfferLayerDelegate) {
        self.delegate = delegate
    }
    
    func loadPullOffers() {
        self.loadPullOffersSuperUseCase.execute()
        UseCaseWrapper(with: trusteerUseCase, useCaseHandler: useCaseHandler)
    }
}

extension LoginPullOfferLayer: SetupPublicPullOffersSuperUseCaseDelegate {
    func onSuccess() {
        self.delegate?.loadPullOffersSuccess()
        self.getCandidateOffers { [weak self] offers in
            self?.delegate?.didLoadCandidatePullOffers(offers)
        }
    }
}

private extension LoginPullOfferLayer {
    func getCandidateOffers(completion: @escaping ([PullOfferLocation: OfferEntity]) -> Void) {
        let input = PullOfferCandidatesUseCaseInput(locations: locations)
        let useCase = self.pullOfferCandidatesUseCase.setRequestValues(requestValues: input)
        UseCaseWrapper(with: useCase,
                       useCaseHandler: useCaseHandler,
                       onSuccess: { result in
                        completion(result.candidates)
        })
    }
}
