import CoreFoundationLib

public struct PublicProductsRepository: BaseRepository {
    public typealias T = PublicProductsDTO
    public let datasource: NetDataSource<PublicProductsDTO, PublicProductsParser>
    
    init(netClient: NetClient, assetsClient: AssetsClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "public_products.json")
        let parser = PublicProductsParser()
        self.datasource = NetDataSource<PublicProductsDTO, PublicProductsParser>(parser: parser, parameters: parameters, assetsClient: assetsClient, netClient: netClient)
    }
}

extension PublicProductsRepository: PublicProductsRepositoryProtocol {
    public func getPublicProducts() -> PublicProductsDTO? {
        return get()
    }
    
    public func loadProduct(baseUrl: String, publicLanguage: PublicLanguage) {
        self.load(baseUrl: baseUrl, publicLanguage: publicLanguage)
    }
}
