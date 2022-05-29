import CoreFoundationLib

struct DownloadsRepositoryBuilder {
    let appRepository: AppRepository
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver, appRepository: AppRepository) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = appRepository
    }
    
    func build() -> DownloadsRepository {
        let services = NetworkServiceImpl(callExecutor: NetworkURLSessionExecutor(dependenciesResolver: dependenciesResolver))
        let persistance = DownloadsPersistanceDataSourceImpl(pdfCache: AppDocumentsCacheImpl(relativePath: "PDFCache"))
        
        return DownloadsRepositoryImpl(appRepository: appRepository, networkService: services, persistanceDataSource: persistance)
    }
}
