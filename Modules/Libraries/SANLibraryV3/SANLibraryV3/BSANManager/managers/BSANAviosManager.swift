import SANLegacyLibrary

public final class BSANAviosManagerImplementation: BSANBaseManager, BSANAviosManager {
    private let sanRestServices: SanRestServices
    
    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getAviosDetail() throws -> BSANResponse<AviosDetailDTO> {
        let dataSource = GetAviosDetailDataSource(sanRestServices: sanRestServices,
                                                  bsanDataProvider: bsanDataProvider)
        return try dataSource.getAviosInfo()
    }
}
