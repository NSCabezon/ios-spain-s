import CoreFoundationLib

struct DataRepositoryAppInfoBuilder {
    let appInfo: VersionInfoDTO
    
    func build() -> DataRepository {
        let memoryDataSource = MemoryDataSource()
        let sharedKeyChainService = SharedKeyChainService(accessGroupName: Compilation.Keychain.sharedTokenAccessGroup)
        let bbddDataSource: BBDDDataSource = BBDDDataSource(serializer: JSONSerializer(), keychainService: sharedKeyChainService, appInfo: appInfo)
        let dataSources: [DataSource] = [bbddDataSource, memoryDataSource]
        return DataRepositoryImpl(dataSourceProvider: DataSourceProviderImpl(defaultDataSource: memoryDataSource, dataSources: dataSources), appInfo: appInfo)
    }
}
