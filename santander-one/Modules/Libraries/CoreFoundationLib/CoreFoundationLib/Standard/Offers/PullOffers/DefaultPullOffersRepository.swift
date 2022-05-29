import CoreDomain
import OpenCombine

public class DefaultPullOffersRepository {
    private let pullOffersPersistenceDataSource: PullOffersPersistenceDataSource
    private var safeVisitedLocations: ThreadSafeProperty<Set<String>> = ThreadSafeProperty([])
    private var safeSessionDisabledOffers: ThreadSafeProperty<Set<String>> = ThreadSafeProperty([])
    
    public var visitedLocations: Set<String> {
        get {
            return safeVisitedLocations.value
        }
        set {
            safeVisitedLocations.value = newValue
        }
    }
    
    public var sessionDisabledOffers: Set<String> {
        get {
            return safeSessionDisabledOffers.value
        }
        set {
            safeSessionDisabledOffers.value = newValue
        }
    }
    
    public init(pullOffersPersistenceDataSource: PullOffersPersistenceDataSource) {
        self.pullOffersPersistenceDataSource = pullOffersPersistenceDataSource
    }
}

extension DefaultPullOffersRepository: PullOffersRepositoryProtocol {
    public func getPullOffersInfo(userId: String, offerId: String) -> RepositoryResponse<PullOffersInfoDTO> {
        return LocalResponse(pullOffersPersistenceDataSource.getPullOffersInfo(userId: userId, offerId: offerId))
    }
    
    public func removePullOffersInfo(userId: String, offerId: String) -> RepositoryResponse<Void> {
        pullOffersPersistenceDataSource.removePullOffersInfo(userId: userId, offerId: offerId)
        return OkEmptyResponse()
    }
    
    public func expireOffer(userId: String, offerId: String) -> RepositoryResponse<Void> {
        pullOffersPersistenceDataSource.expireOffer(userId: userId, offerId: offerId)
        return OkEmptyResponse()
    }
    
    public func visitOffer(userId: String, offerId: String) -> RepositoryResponse<Void> {
        pullOffersPersistenceDataSource.visitOffer(userId: userId, offerId: offerId)
        return OkEmptyResponse()
    }
    
    public func setRule(identifier: String, isValid: Bool) -> RepositoryResponse<Void> {
        pullOffersPersistenceDataSource.getPullOffersData()?.setRule(identifier: identifier, isValid: isValid)
        return OkEmptyResponse()
    }
    
    public func isValidRule(identifier: String) -> RepositoryResponse<Bool> {
        return LocalResponse(pullOffersPersistenceDataSource.getPullOffersData()?.isValidRule(identifier: identifier))
    }
    
    public func setOffer(location: String, offerId: String?) -> RepositoryResponse<Void> {
        pullOffersPersistenceDataSource.getPullOffersData()?.setOffer(location: location, offerId: offerId)
        return OkEmptyResponse()
    }
    
    public func removeOffer(location: String) -> RepositoryResponse<Void> {
        pullOffersPersistenceDataSource.getPullOffersData()?.removeOffer(location: location)
        return OkEmptyResponse()
    }
    
    public func getOffer(location: String) -> RepositoryResponse<String> {
        return LocalResponse(pullOffersPersistenceDataSource.getPullOffersData()?.getOffer(location: location))
    }
    
    public func removePullOffersData() -> RepositoryResponse<Void> {
        pullOffersPersistenceDataSource.getPullOffersData()?.reset()
        return OkEmptyResponse()
    }
    
    public func setup() -> RepositoryResponse<Void> {
        let pullOffersDataDTO = PullOffersDataDTO()
        pullOffersPersistenceDataSource.setPullOffersData(pullOffersDataDTO: pullOffersDataDTO)
        return OkEmptyResponse()
    }
    
    public func reset() -> RepositoryResponse<Void> {
        pullOffersPersistenceDataSource.removePullOffersData()
        return OkEmptyResponse()
    }
    
    public func visitLocation(location: String) {
        visitedLocations.insert(location)
    }
}

extension DefaultPullOffersRepository: ReactivePullOffersRepository {
    public func fetchOfferInfoPublisher(with identifier: String, userId: String) -> AnyPublisher<PullOfferInfoRepresentable, Error> {
        return Future { promise in
            guard
                let response = try? self.getPullOffersInfo(userId: userId, offerId: identifier).getResponseData()
            else {
                return promise(.failure(RepositoryError.unknown))
            }
            promise(.success(response))
        }.eraseToAnyPublisher()
    }
    
    public func fetchOfferPublisher(for location: PullOfferLocationRepresentable) -> AnyPublisher<String, Error> {
        return Future { promise in
            guard
                let response = try? self.getOffer(location: location.stringTag).getResponseData()
            else {
                return promise(.failure(RepositoryError.unknown))
            }
            promise(.success(response))
        }
        .eraseToAnyPublisher()
    }
    
    public func fetchVisitedLocations() -> AnyPublisher<[String], Never> {
        return Just(Array(visitedLocations)).eraseToAnyPublisher()
    }
    
    public func visitLocation(_ location: String) {
        visitedLocations.insert(location)
    }
    
    public func fetchSessionDisabledOffers() -> AnyPublisher<[String], Never> {
        return Just(Array(sessionDisabledOffers)).eraseToAnyPublisher()
    }
    
    public func disableOfferInSession(_ offer: String) {
        sessionDisabledOffers.insert(offer)
    }
    
    public func visitOffer(_ offer: String, userId: String) {
        _ = visitOffer(userId: userId, offerId: offer)
    }
    
    public func setRule(identifier: String, isValid: Bool) {
        pullOffersPersistenceDataSource.getPullOffersData()?.setRule(identifier: identifier, isValid: isValid)
    }
    
    public func isValidRule(identifier: String) -> AnyPublisher<Bool?, Never> {
        guard
            let response = try? LocalResponse(self.pullOffersPersistenceDataSource.getPullOffersData()?.isValidRule(identifier: identifier)),
            let responseData = try? response.getResponseData()
        else { return Just(nil).eraseToAnyPublisher() }
        return Just(responseData).eraseToAnyPublisher()
    }
}
