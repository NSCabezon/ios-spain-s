import SANLegacyLibrary

struct MockBSANEcommerceManager: BSANEcommerceManager {
    func getOperationData(shortUrl: String) throws -> BSANResponse<EcommerceOperationDataDTO> {
        fatalError()
    }
    
    func getLastOperationShortUrl(documentType: String, documentNumber: String, tokenPush: String) throws -> BSANResponse<EcommerceLastOperationShortUrlDTO> {
        fatalError()
    }
    
    func confirmWithAccessKey(shortUrl: String, key: String) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func confirmWithFingerPrint(input: EcommerceConfirmWithFingerPrintInputParams) throws -> BSANResponse<Void> {
        fatalError()
    }
}
