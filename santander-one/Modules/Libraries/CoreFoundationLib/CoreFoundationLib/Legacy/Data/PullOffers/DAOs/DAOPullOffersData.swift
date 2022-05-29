public protocol DAOPullOffersData {
    func remove() -> Bool
    func set(pullOffersDataDTO: PullOffersDataDTO) -> Bool
    func get() -> PullOffersDataDTO?
}
