import CoreFoundationLib
import SANLibraryV3
import CoreFoundationLib
import Foundation
import CommonAppExtensions
import RetailLegacy

final class WidgetDependencies {
    static var loginUseCase: UseCase<Void, ExtensionsLoginUseCaseOkOutput, StringErrorOutput> {
        return WidgetLoginUseCase(bsanManagersProvider: bsanManager, daoSharedPersistedUser: daoSharedPersistedUser, netInsightRepository: netInsightRepository)
    }
    static var localAppConfig: LocalAppConfig = {
        return SpainAppConfig()
    }()
    static var languageUseCas: UseCase<Void, WidgetLanguageUseCaseOkOutput, StringErrorOutput> {
        return WidgetLanguageUseCase(localAppConfig: localAppConfig, daoSharedPersistedUser: daoSharedPersistedUser, daoLanguage: daoLanguage)
    }
    static var usecaseHandler: UseCaseHandler = {
        return UseCaseHandler()
    }()
    static var localeManger: TimeManager&StringLoader {
        return LocaleManager(localAppConfig: self.localAppConfig, useCaseProvider: useCaseProvider, useCaseHandler: usecaseHandler)
    }
    static var getDataSnapshotUseCase: UseCase<Void, WidgetGetDataSnapshotUseCaseOkOutput, StringErrorOutput> {
        return WidgetGetDataSnapshotUseCase(daoDataSnapshot: daoDataSnapshot)
    }
    static var trackerManager: TrackerManager = {
        return TrackerManagerImpl(usecaseProvider: useCaseProvider, usecaseHandler: usecaseHandler)
    }()
    private static var useCaseProvider: WidgetUseCaseProvider = {
        return WidgetUseCaseProvider()
    }()
    private static var tealiumRepository: TealiumRepository = {
        return TealiumRepositoryImpl()
    }()
    private static var widgetRepository: WidgetRepository = {
        return WidgetRepositoryImpl(daoLanguage: daoLanguage)
    }()
    private static var netInsightRepository: NetInsightRepository = {
        return NetInsightRepositoryImpl(networkService: networkService)
    }()
    private static var networkService: NetworkService = {
        NetworkServiceImpl(callExecutor: NetworkURLSessionExecutor())
    }()
    private static var dataRepository: DataRepository = {
        DataRepositoryAppInfoBuilder(appInfo: versionInfo).build()
    }()
    private static var daoDataSnapshot: DAODataSnapshot = {
        return DAODataSnapshotImpl(dataRepository: dataRepository)
    }()
    private static var bsanManager: BSANManagersProvider = {
        let bsanDataProvider = BSANDataProvider(dataRepository: dataRepository, appInfo: versionInfo)
        let targetProvider = TargetProviderImpl(webServicesUrlProvider: WebServicesUrlProviderImpl(bsanDataProvider: bsanDataProvider), bsanDataProvider: bsanDataProvider)
        let bsanManager = BSANManagersProviderBuilder(bsanDataProvider: bsanDataProvider, targetProvider: targetProvider, hostModule: HostModule()).build()
        return bsanManager
    }()
    private static var versionInfo: VersionInfoDTO = { VersionInfoDTO(bundleIdentifier: Bundle.main.bundleIdentifier ?? "", versionName: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String  ?? "")
    }()
    private static var udDataSource: UDDataSource = {
        let sharedKeyChainService = SharedKeyChainService(accessGroupName: Compilation.Keychain.sharedTokenAccessGroup)
        return UDDataSource(serializer: JSONSerializer(), appInfo: versionInfo, keychainService: sharedKeyChainService, domain: .suite(name: Compilation.appGroupsIdentifier))
    }()
    private static var udDataRepository: DataRepository = {
        return DataRepositoryImpl(dataSourceProvider: DataSourceProviderImpl(defaultDataSource: udDataSource, dataSources: [udDataSource]), appInfo: versionInfo)
    }()
    private static var daoSharedPersistedUser: DAOSharedPersistedUserProtocol = {
        return DAOSharedPersistedUser(dataRepository: udDataRepository)
    }()
    private static var daoUserPref: DAOUserPref = {
        return DAOUserPrefImpl(dataRepository: udDataRepository, secondarySaverDataRepository: nil)
    }()
    private static var daoLanguage: DAOLanguage = {
        return DAOLanguageImpl(dataRepository: udDataRepository, secondarySaverDataRepository: nil)
    }()
    private static var daoSharedAppConfig: DAOSharedAppConfig = {
        return DAOSharedAppConfigImpl(dataRepository: udDataRepository)
    }()
    
    static func accountsUseCase(input: WidgetAccountUseCaseInput) -> UseCase<WidgetAccountUseCaseInput, WidgetAccountUseCaseOkOutput, StringErrorOutput> {
        return WidgetAccountUseCase(bsanManagersProvider: bsanManager, daoUserPref: daoUserPref, daoSharedAppConfig: daoSharedAppConfig).setRequestValues(requestValues: input)
    }
    
    static func accountTransactionsUseCase(input: WidgetAccountTransactionsUseCaseInput) -> UseCase<WidgetAccountTransactionsUseCaseInput, WidgetAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
        return WidgetAccountTransactionsUseCase(bsanManagersProvider: bsanManager).setRequestValues(requestValues: input)
    }
    
    static func accountTransactionsUseCase(delegate: WidgetAccountsTransactionsSuperUseCaseDelegate) -> WidgetAccountsTransactionsSuperUseCaseProtocol {
        return WidgetAccountsTransactionsSuperUseCase(delegate: delegate, useCaseHandler: usecaseHandler)
    }
    
    static func userUseCase(input: WidgetUserUseCaseInput) -> UseCase<WidgetUserUseCaseInput, WidgetUserUseCaseOkOutput, StringErrorOutput> {
        return WidgetUserUseCase(daoSharedPersistedUser: daoSharedPersistedUser).setRequestValues(requestValues: input)
    }
    
    static func setDataSnapshotUseCase(input: WidgetSetDataSnapshotUseCaseInput) -> UseCase<WidgetSetDataSnapshotUseCaseInput, Void, StringErrorOutput> {
        return WidgetSetDataSnapshotUseCase(daoDataSnapshot: daoDataSnapshot).setRequestValues(requestValues: input)
    }
    static func metricsTrackUseCase(input: MetricsTrackUseCaseInput) ->  UseCase<MetricsTrackUseCaseInput, Void, StringErrorOutput> {
        return MetricsTrackUseCase(localAppConfig: self.localAppConfig, tealiumRepository: tealiumRepository, netInsightRepository: netInsightRepository, languageRepository: widgetRepository).setRequestValues(requestValues: input)
    }
}
