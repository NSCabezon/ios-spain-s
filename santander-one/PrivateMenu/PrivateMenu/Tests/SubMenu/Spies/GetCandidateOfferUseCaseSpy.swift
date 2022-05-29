//
//  GetCandidateOfferUseCaseSpy.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain
import CoreFoundationLib
import OpenCombine
import PrivateMenu

class GetCandidateOfferUseCaseSpy: GetCandidateOfferUseCase {
    var fetchCandidateOfferCalled: Bool = false
    
    func fetchCandidateOfferPublisher(location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable, Error> {
        fetchCandidateOfferCalled = true
        let pullOfferLocation = MockPullOfferLocation(stringTag: "", hasBanner: false)
        return Just(pullOfferLocation).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
