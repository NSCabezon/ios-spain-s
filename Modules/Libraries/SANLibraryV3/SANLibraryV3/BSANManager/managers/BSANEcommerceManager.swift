import SANLegacyLibrary

public final class BSANEcommerceManagerImplementation: BSANBaseManager, BSANEcommerceManager {
    private let sanRestServices: SanRestServices

    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }

    public func getOperationData(shortUrl: String) throws -> BSANResponse<EcommerceOperationDataDTO> {
        let dataSource = EcommerceDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        return try dataSource.getOperationData(shortUrl: shortUrl)
    }

    public func getLastOperationShortUrl(documentType: String, documentNumber: String, tokenPush: String) throws -> BSANResponse<EcommerceLastOperationShortUrlDTO> {
        let dataSource = EcommerceDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        return try dataSource.getLastOperationShortUrl(documentType: documentType,
                                                       documentNumber: documentNumber,
                                                       tokenPush: tokenPush)
    }

    public func confirmWithAccessKey(shortUrl: String, key: String) throws -> BSANResponse<Void> {
        let dataSource = EcommerceDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        return try dataSource.confirmWithAccessKey(shortUrl: shortUrl, key: key)
    }

    public func confirmWithFingerPrint(input: EcommerceConfirmWithFingerPrintInputParams) throws -> BSANResponse<Void>
 {
        let dataSource = EcommerceDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        return try dataSource.confirmWithFingerPrint(input: input)
    }
}
