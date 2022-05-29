import CoreFoundationLib

public struct AppInfoRepository: BaseRepository {
    public typealias T = AppInfoDTO
    public let datasource: NetDataSource<AppInfoDTO, AppInfoParser>
    
    init(netClient: NetClient, assetsClient: AssetsClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/newArq/ios/", fileName: "app_info.json")
        let parser = AppInfoParser()
        datasource = NetDataSource<AppInfoDTO, AppInfoParser>(parser: parser, parameters: parameters, assetsClient: assetsClient, netClient: netClient)
    }
}

extension AppInfoRepository: AppInfoRepositoryProtocol {
    public func getAppInfo() -> AppVersionsInfoDTO? {
        return AppVersionsInfoDTO(versions: self.get()?.getVersions ?? [:] )
    }
    
    public func load(baseUrl: String, publicLanguage: PublicLanguage) {
        datasource.load(baseUrl: baseUrl, publicLanguage: publicLanguage)
    }
}
