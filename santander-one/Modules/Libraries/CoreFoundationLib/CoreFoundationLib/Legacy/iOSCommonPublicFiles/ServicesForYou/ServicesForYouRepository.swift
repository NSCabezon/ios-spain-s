import Foundation


public struct ServicesForYouRepository: BaseRepository {
    public typealias T = ServicesForYouDTO
    public let datasource: NetDataSource<ServicesForYouDTO, ServicesForYouParser>
    
    public init(netClient: NetClient, assetsClient: AssetsClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "apps/smart123/", fileName: "services4u.json")
        let parser = ServicesForYouParser()
        datasource = NetDataSource<ServicesForYouDTO, ServicesForYouParser>(parser: parser, parameters: parameters, assetsClient: assetsClient, netClient: netClient)
    }
}
