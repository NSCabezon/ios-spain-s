import SANLegacyLibrary

public final class BSANFintechManagerImplementation: BSANBaseManager, BSANFintechManager {
    private let sanRestServices: SanRestServices

    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }

    public func confirmWithAccessKey(authenticationParams: FintechUserAuthenticationInputParams, userInfo: FintechUserInfoAccessKeyParams) throws -> BSANResponse<FintechAccessConfimationResponseDTO> {
        let dataSource = FintechDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        return try dataSource.confirmWithAccessKey(authenticationParams: authenticationParams, userInfo: userInfo)
    }

    public func confirmWithFootprint(authenticationParams: FintechUserAuthenticationInputParams, userInfo: FintechUserInfoFootprintParams) throws -> BSANResponse<FintechAccessConfimationResponseDTO> {
        let dataSource = FintechDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        return try dataSource.confirmWithAccessKey(authenticationParams: authenticationParams, userInfo: userInfo)
    }
}
