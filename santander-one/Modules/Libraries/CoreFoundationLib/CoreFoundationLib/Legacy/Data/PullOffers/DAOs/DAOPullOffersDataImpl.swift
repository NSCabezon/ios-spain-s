public class DAOPullOffersDataImpl {
    var pullOffersDataDTO: PullOffersDataDTO?
    public init() {}
}

public extension DAOPullOffersDataImpl {
    func remove() -> Bool {
        pullOffersDataDTO = nil
        return true
    }
    
    func set(pullOffersDataDTO: PullOffersDataDTO) -> Bool {
        self.pullOffersDataDTO = pullOffersDataDTO
        return true
    }
    
    func get() -> PullOffersDataDTO? {
        return pullOffersDataDTO
    }
}

extension DAOPullOffersDataImpl: DAOPullOffersData {}
