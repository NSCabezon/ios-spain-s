//
//  TripListPresenter+extension.swift
//  PersonalArea
//
//  Created by Juan Carlos López Robles on 3/23/20.
//

import Foundation
import CoreFoundationLib

extension TripListPresenter {

    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    private var getPullOfferUseCase: GetPullOffersUseCase {
        return self.dependenciesResolver.resolve(for: GetPullOffersUseCase.self)
    }
    
    func loadPullOffer(completion: @escaping() -> Void) {
        let input =  GetPullOffersUseCaseInput(locations: locations)
        UseCaseWrapper(
            with: self.getPullOfferUseCase.setRequestValues(requestValues: input),
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] response in
                self?.offers = response.pullOfferCandidates
                completion()
            }, onError: {_ in
                completion()
        })
    }
}
