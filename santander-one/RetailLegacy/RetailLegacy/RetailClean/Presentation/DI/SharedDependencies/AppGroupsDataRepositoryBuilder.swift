import CoreFoundationLib

struct AppGroupsDataRepositoryBuilder {
    let appInfo: VersionInfoDTO
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver, appInfo: VersionInfoDTO) {
        self.appInfo = appInfo
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    func build() -> DataRepository {
        let sharedKeyChainService = SharedKeyChainService(accessGroupName: compilation.keychain.sharedTokenAccessGroup)
        let udDataSource: UDDataSource = UDDataSource(serializer: JSONSerializer(),
                                                      appInfo: appInfo,
                                                      keychainService: sharedKeyChainService,
                                                      domain: .suite(name: compilation.appGroupsIdentifier))
        return DataRepositoryImpl(dataSourceProvider: DataSourceProviderImpl(defaultDataSource: udDataSource, dataSources: [udDataSource]), appInfo: appInfo)
    }
}
