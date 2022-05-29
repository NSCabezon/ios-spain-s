import CoreFoundationLib

struct DataRepositoryBuilder {
    let appInfo: VersionInfoDTO
    
    func build() -> DataRepository {
        let memoryDataSource = MemoryDataSource()
        let dataSources: [DataSource] = [memoryDataSource]
        return DataRepositoryImpl(dataSourceProvider: DataSourceProviderImpl(defaultDataSource: memoryDataSource, dataSources: dataSources), appInfo: appInfo)
    }
}
