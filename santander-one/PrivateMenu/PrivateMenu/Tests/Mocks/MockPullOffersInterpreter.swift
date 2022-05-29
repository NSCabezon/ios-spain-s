//
//  MockPullOffersInterpreter.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 3/5/22.
//

import CoreFoundationLib

final class MockPullOffersInterpreter: PullOffersInterpreter {
    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool {
        return false
    }
    
    func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]? {
        return nil
    }
    
    func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO? {
        return nil
    }
    
    func getValidOffer(offerId: String) -> OfferDTO? {
        return nil
    }
    
    func getOffer(offerId: String) -> OfferDTO? {
        return nil
    }
    
    func setCandidates(locations: [String : [String]], userId: String, reload: Bool) {}
    
    func expireOffer(userId: String, offerDTO: OfferDTO) {}
    
    func removeOffer(location: String) {}
    
    func disableOffer(identifier: String?) {}
    
    func reset() {}
    
    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool {
        return false
    }
}
