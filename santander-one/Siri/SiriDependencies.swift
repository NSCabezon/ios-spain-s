import SANLibraryV3
import CoreFoundationLib
import Foundation
import CommonAppExtensions
import RetailLegacy

@available(iOS 12.0, *)
final class SiriDependencies {
    var loginUseCase: UseCase<Void, ExtensionsLoginUseCaseOkOutput, StringErrorOutput> {
        return SiriLoginUseCase(bsanManagersProvider: bsanManager, daoSharedPersistedUser: daoSharedPersistedUser)
    }
    
    var getManagersUseCase: UseCase<Void, SiriGetManagersUseCaseOkOutput, StringErrorOutput> {
        return SiriGetManagersUseCase(bsanManagersProvider: bsanManager, daoSharedAppConfig: daoSharedAppConfig)
    }
    
    lazy var usecaseHandler: UseCaseHandler = {
        return UseCaseHandler()
    }()
    
    private lazy var dataRepository: DataRepository = {
        return DataRepositoryAppInfoBuilder(appInfo: versionInfo).build()
    }()
    
    private lazy var bsanManager: BSANManagersProvider = {
        let bsanDataProvider = BSANDataProvider(dataRepository: dataRepository, appInfo: versionInfo)
        let targetProvider = TargetProviderImpl(webServicesUrlProvider: WebServicesUrlProviderImpl(bsanDataProvider: bsanDataProvider), bsanDataProvider: bsanDataProvider)
        let bsanManager = BSANManagersProviderBuilder(bsanDataProvider: bsanDataProvider, targetProvider: targetProvider, hostModule: HostModule()).build()
        return bsanManager
    }()
    
    private lazy var daoSharedAppConfig: DAOSharedAppConfig = {
        return DAOSharedAppConfigImpl(dataRepository: udDataRepository)
    }()
    
    private lazy var versionInfo: VersionInfoDTO = {
        return VersionInfoDTO(bundleIdentifier: Bundle.main.bundleIdentifier ?? "", versionName: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String  ?? "")
    }()
    
    private lazy var udDataSource: UDDataSource = {
        let sharedKeyChainService = SharedKeyChainService(accessGroupName: Compilation.Keychain.sharedTokenAccessGroup)
        return UDDataSource(serializer: JSONSerializer(), appInfo: versionInfo, keychainService: sharedKeyChainService, domain: .suite(name: Compilation.appGroupsIdentifier))
    }()
    
    private lazy var udDataRepository: DataRepository = {
        return DataRepositoryImpl(dataSourceProvider: DataSourceProviderImpl(defaultDataSource: udDataSource, dataSources: [udDataSource]), appInfo: versionInfo)
    }()
    
    private lazy var daoSharedPersistedUser: DAOSharedPersistedUser = {
        return DAOSharedPersistedUser(dataRepository: udDataRepository)
    }()
}
