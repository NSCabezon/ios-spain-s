public protocol BSANEcommerceManager {
    func getOperationData(shortUrl: String) throws -> BSANResponse<EcommerceOperationDataDTO>
    func getLastOperationShortUrl(documentType: String, documentNumber: String,  tokenPush: String) throws -> BSANResponse<EcommerceLastOperationShortUrlDTO>
    func confirmWithAccessKey(shortUrl: String, key: String) throws -> BSANResponse<Void>
    func confirmWithFingerPrint(input: EcommerceConfirmWithFingerPrintInputParams) throws -> BSANResponse<Void>
}
