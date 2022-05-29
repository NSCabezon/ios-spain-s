public protocol PullOffersPersistenceDataSource {
    func getPullOffersInfo(userId: String, offerId: String) -> PullOffersInfoDTO
    func removePullOffersInfo(userId: String, offerId: String)
    
    func expireOffer(userId: String, offerId: String)
    func visitOffer(userId: String, offerId: String)
    
    func getPullOffersData() -> PullOffersDataDTO?
    func setPullOffersData(pullOffersDataDTO: PullOffersDataDTO)
    func removePullOffersData()
}
