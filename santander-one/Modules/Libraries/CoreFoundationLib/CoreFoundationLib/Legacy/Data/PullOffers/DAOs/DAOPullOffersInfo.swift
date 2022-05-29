public protocol DAOPullOffersInfo {
    func remove(userId: String, offerId: String) -> Bool
    func set(pullOffersInfo: PullOffersInfoDTO) -> Bool
    func get(userId: String, offerId: String) -> PullOffersInfoDTO?
}
