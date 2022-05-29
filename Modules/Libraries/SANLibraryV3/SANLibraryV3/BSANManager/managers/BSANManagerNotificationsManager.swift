import SANLegacyLibrary

public final class BSANManagerNotificationsManagerImplementation: BSANBaseManager, BSANManagerNotificationsManager {
    
    let sanRestServices: SanRestServices
    
    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getManagerNotificationsInfo() throws -> BSANResponse<ManagerNotificationsDTO> {
        let dataSource = ManagerNotificationsDataSource(sanRestServices: sanRestServices,
                                                        bsanDataProvider: bsanDataProvider)
        return try dataSource.getManagerNotifications()
    }
}
