

public class AccountDescriptorRepository: BaseRepository {
    public typealias T = AccountDescriptorArrayDTO
    public let datasource: FullDataSource<AccountDescriptorArrayDTO, AccountDescriptorParser>
    
    public init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "apps/SAN/", fileName: "accountsInfo.xml")
        let parser = AccountDescriptorParser()
        datasource = FullDataSource<AccountDescriptorArrayDTO, AccountDescriptorParser>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}
