public protocol PullOffersInterpreter {
    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool
    func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]?
    func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO?
    func getValidOffer(offerId: String) -> OfferDTO?
    func getOffer(offerId: String) -> OfferDTO?
    func setCandidates(locations: [String: [String]], userId: String, reload: Bool)
    func expireOffer(userId: String, offerDTO: OfferDTO)
    func removeOffer(location: String)
    func disableOffer(identifier: String?)
    func reset()
    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool
}
