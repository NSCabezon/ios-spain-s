import CoreFoundationLib

class AppConfigDataSource: FullDataSource<AppConfigDTO, CodableParser<AppConfigDTO>> {
    let versionName: String
    
    init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient, versionName: String) {
        let parameters = BaseDataSourceParameters(relativeURL: "apps/newArq/ios/", fileName: "app_config_v2.json")
        let parser = CodableParser<AppConfigDTO>()
        self.versionName = versionName
        super.init(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
    
    public override func storeOnFile(_ baseUrl: String) {
        parseVersions()
        super.storeOnFile(baseUrl)
    }
    
    private func parseVersions() {
        if let appConfig = dto, let versions = appConfig.getVersions, let version = versions[versionName], var defaultConfig = appConfig.getDefaultConfig {
            for (key, value) in version {
                defaultConfig[key] = value
            }
            dto?.defaultConfig = defaultConfig
        }
    }
}
