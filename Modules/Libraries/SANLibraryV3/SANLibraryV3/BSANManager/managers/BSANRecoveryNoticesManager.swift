import SANLegacyLibrary

public final class BSANRecoveryNoticesManagerImplementation: BSANBaseManager, BSANRecoveryNoticesManager {
    
    private let sanRestServices: SanRestServices
    
    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getRecoveryNotices() throws -> BSANResponse<[RecoveryDTO]> {
        if let recoveryCached = try self.bsanDataProvider.get(\.recoveryNotices) {
            return BSANOkResponse(recoveryCached)
        }
        let dataSource = RecoveryNoticesDataSource(sanRestServices: sanRestServices,
                                                   bsanDataProvider: bsanDataProvider)
        let response = try dataSource.getRecoveryNotices()
        if response.isSuccess(), let recoveryDTOs = try response.getResponseData() {
            self.bsanDataProvider.store(recoveryDTOs: recoveryDTOs)
        }
        return response
    }
}
