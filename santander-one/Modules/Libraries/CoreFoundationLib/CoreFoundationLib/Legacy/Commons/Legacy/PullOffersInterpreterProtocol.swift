
public protocol PullOffersInterpreterProtocol {
    func getCandidate(userId: String, location: PullOfferLocationProtocol) -> OfferDTOProtocol?
}
