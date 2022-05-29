import Foundation

public class LocalPullOffersPersistenceDataSource {
    private let daoPullOffersInfo: DAOPullOffersInfo
    private let daoPullOffersData: DAOPullOffersData

    public init(daoPullOffersInfo: DAOPullOffersInfo, daoPullOffersData: DAOPullOffersData) {
        self.daoPullOffersInfo = daoPullOffersInfo
        self.daoPullOffersData = daoPullOffersData
    }
}

public extension LocalPullOffersPersistenceDataSource {
    func getPullOffersInfo(userId: String, offerId: String) -> PullOffersInfoDTO {
        let pullOffersInfoDTO: PullOffersInfoDTO
        objc_sync_enter(daoPullOffersInfo)
        
        if let pullOffersInfoDTOFromDb = daoPullOffersInfo.get(userId: userId, offerId: offerId) {
            pullOffersInfoDTO = pullOffersInfoDTOFromDb
        } else {
            pullOffersInfoDTO = PullOffersInfoDTO(offerId: offerId, userId: userId, expired: false, iterations: 0)
            _ = daoPullOffersInfo.set(pullOffersInfo: pullOffersInfoDTO)
        }
        
        objc_sync_exit(daoPullOffersInfo)
        return pullOffersInfoDTO
    }
    
    func removePullOffersInfo(userId: String, offerId: String) {
        objc_sync_enter(daoPullOffersInfo)
        _ = daoPullOffersInfo.remove(userId: userId, offerId: offerId)
        objc_sync_exit(daoPullOffersInfo)
    }
    
    func expireOffer(userId: String, offerId: String) {
        objc_sync_enter(daoPullOffersInfo)
        
        if var pullOffersInfoDTO = daoPullOffersInfo.get(userId: userId, offerId: offerId) {
            pullOffersInfoDTO.expired = true
            _ = daoPullOffersInfo.set(pullOffersInfo: pullOffersInfoDTO)
        }
        
        objc_sync_exit(daoPullOffersInfo)
    }
    
    func visitOffer(userId: String, offerId: String) {
        objc_sync_enter(daoPullOffersInfo)
        
        if var pullOffersInfoDTO = daoPullOffersInfo.get(userId: userId, offerId: offerId) {
            pullOffersInfoDTO.iterations += 1
            _ = daoPullOffersInfo.set(pullOffersInfo: pullOffersInfoDTO)
        }
        
        objc_sync_exit(daoPullOffersInfo)
    }
    
    func getPullOffersData() -> PullOffersDataDTO? {
        objc_sync_enter(daoPullOffersData)
        let pullOffersDataDTO = daoPullOffersData.get()
        objc_sync_exit(daoPullOffersData)
        return pullOffersDataDTO
    }
    
    func setPullOffersData(pullOffersDataDTO: PullOffersDataDTO) {
        objc_sync_enter(daoPullOffersData)
        _ = daoPullOffersData.set(pullOffersDataDTO: pullOffersDataDTO)
        objc_sync_exit(daoPullOffersData)
    }
    
    func removePullOffersData() {
        objc_sync_enter(daoPullOffersData)
        _ = daoPullOffersData.remove()
        objc_sync_exit(daoPullOffersData)
    }
}

extension LocalPullOffersPersistenceDataSource: PullOffersPersistenceDataSource {}
