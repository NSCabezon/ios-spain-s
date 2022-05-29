import CoreFoundationLib

public struct DataRepositoryBuilder {
    let appInfo: VersionInfoDTO
    private let compilation: CompilationProtocol

    public init(dependenciesResolver: DependenciesResolver) {
        self.appInfo = dependenciesResolver.resolve(for: VersionInfoDTO.self)
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    public func build() -> DataRepository {
        let memoryDataSource = MemoryDataSource()
        let sharedKeyChainService = SharedKeyChainService(accessGroupName: compilation.keychain.sharedTokenAccessGroup)
        let bbddDataSource: BBDDDataSource = BBDDDataSource(serializer: JSONSerializer(), keychainService: sharedKeyChainService, appInfo: appInfo)
        let dataSources: [DataSource] = [bbddDataSource, memoryDataSource]
        return DataRepositoryImpl(dataSourceProvider: DataSourceProviderImpl(defaultDataSource: memoryDataSource, dataSources: dataSources), appInfo: appInfo)
    }
}
