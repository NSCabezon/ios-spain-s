import IQKeyboardManagerSwift
import SANLegacyLibrary
import PersonalManager
import GlobalPosition
import CoreFoundationLib
import Localization
import Alamofire
import Loans
import Inbox
import Cards
import UIKit
import Menu
import UI
import Transfer
import TransferOperatives
import PdfCommons
import CoreDomain

public protocol SharedDependenciesDelegate {
    func publicFilesFinished(_ appConfigRepository: AppConfigRepositoryProtocol)
}

final class SharedDependencies {
    
    private let locationManager: LocationManager = LocationManager()
    private let appEventsNotifier: AppEventsNotifier = AppEventsNotifier()
    private let persistenceDatabaseHelper: PersistenceDatabaseHelper = PersistenceDatabaseHelper()
    private let stylesManager: StylesManager = StylesManager()
    private let pullOffersEngine: EngineInterface = BaseEngine()
    let mainUseCaseHandler: UseCaseHandler = UseCaseHandler(maxConcurrentOperationCount: 8)
    private let globalPositionReloadEngine: GlobalPositionReloadEngine = GlobalPositionReloadEngine()
    private let contactsManager: ContactsStoreManager = ContactsStoreManager()
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private let versionInfo: VersionInfoDTO
    private let dataRepository: DataRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let localAppConfig: LocalAppConfig
    private let coreDependenciesResolver: RetailLegacyExternalDependenciesResolver
    private let cardExternalDependenciesResolver: CardExternalDependenciesResolver

    lazy var navigatorProvider: NavigatorProvider = {
        guard let drawer = UIApplication.shared.delegate?.window??.rootViewController as? BaseMenuViewController else {
            fatalError()
        }
        let navigatorProvider = NavigatorProvider(drawer: drawer, presenterProvider: presenterProvider, dependenciesEngine: dependenciesEngine, legacyExternalDependenciesResolver: coreDependenciesResolver, cardExternalDependenciesResolver: cardExternalDependenciesResolver)
        presenterProvider.navigatorProvider = navigatorProvider
        
        let presentationComponent = PresentationComponent(
            dependenciesEngine: dependenciesEngine,
            useCaseProvider: useCaseProvider,
            useCaseHandler: mainUseCaseHandler,
            secondaryUseCaseHandler: secondaryUseCaseHandler,
            stringLoader: stringLoader,
            imageLoader: imageLoader,
            timeManager: timeManager,
            localeManager: localeManager,
            stylesManager: stylesManager,
            navigatorProvider: navigatorProvider,
            locationManager: locationManager,
            pullOfferActionsManager: pullOfferActionsManager,
            inbentaManager: inbentaManager,
            managerWallManager: managerWallManager,
            deepLinkManager: deepLinkManager,
            trackerManager: trackerManager,
            siriIntentsManager: siriIntentsManager,
            publicFilesManager: publicFilesManager,
            globalPositionReloadEngine: globalPositionReloadEngine,
            contactsManager: contactsManager,
            localAppConfig: localAppConfig,
            localAuthentication: self.localAuthentication)
        presenterProvider.dependencies = presentationComponent
        return navigatorProvider
    }()
    lazy var reachabilityController: Any = {
        return NSNull()
    }()
    var stringLoader: StringLoader & StringLoaderReactive {
        return localeManager
    }
    var timeManager: TimeManager {
        return localeManager
    }
    private lazy var sessionDataManager: SessionDataManager = {
        let manager = DefaultSessionDataManager(dependenciesResolver: dependenciesEngine)
        manager.setDataManagerProcessDelegate(sessionProcessHelperDelegate)
        return manager
    }()
    private lazy var sessionProcessHelperDelegate: ReloadSessionDelegate = {
        let delegate = ReloadSessionDelegate(stringLoader: stringLoader, globalPositionReloadEngine: globalPositionReloadEngine)
        let completionError: (String?) -> Void = { [weak self] error in
            self?.sessionManager.finishWithReason(.failedGPReload(reason: error))
        }
        let completionSuccess: () -> Void = { [weak self] in
            self?.sessionManager.sessionStarted(completion: nil)
        }
        delegate.onError = completionError
        delegate.onSuccess = completionSuccess
        return delegate
    }()
    private lazy var colorsByNameEngine: ColorsByNameEngine = { ColorsByNameEngine() }()
    private lazy var contactsEngine: ContactsEngineProtocol = {
        return ContactsEngine(dependenciesResolver: self.dependenciesEngine)
    }()
    private lazy var hostModule: HostsModuleProtocol = {
        return self.dependenciesEngine.resolve(for: HostsModuleProtocol.self)
    }()
    private lazy var compilation: CompilationProtocol = {
        return self.dependenciesEngine.resolve(for: CompilationProtocol.self)
    }()
    private lazy var sharedKeyChainService: SharedKeyChainService = {
        return SharedKeyChainService(accessGroupName: compilation.keychain.sharedTokenAccessGroup)
    }()
    private lazy var daoPersistedUser: DAOPersistedUserProtocol = {
        return DAOPersistedUser(persistenceDatabaseHelper: persistenceDatabaseHelper, keychainService: sharedKeyChainService, serializer: JSONSerializer())
    }()
    private lazy var daoSharedPersistedUser: DAOSharedPersistedUserProtocol = {
        return DAOSharedPersistedUser(dataRepository: appGroupsDataRepository)
    }()
    private lazy var daoUserPref: DAOUserPref = {
        return DAOUserPrefImpl(dataRepository: dataRepository,
                               secondarySaverDataRepository: appGroupsDataRepository)
    }()
    private lazy var daoUserPrefEntity: DAOUserPrefEntityProtocol = {
        return DAOUserPrefEntity(dataRepository: dataRepository,
                                 secondarySaverDataRepository: appGroupsDataRepository)
    }()
    private lazy var daoSharedUserPrefEntity: DAOSharedUserPrefEntityProtocol = {
        return DAOSharedUserPrefEntity(dataRepository: appGroupsDataRepository)
    }()
    private lazy var daoPublicFilesEnvironment: DAOPublicFilesEnvironment = {
        return DAOPublicFilesEnvironmentImpl(dataRepository: dataRepository)
    }()
    private lazy var daoInbentaEnvironment: DAOInbentaEnvironment = {
        return DAOInbentaEnvironmentImpl(dataRepository: dataRepository)
    }()
    private lazy var daoPersistedUserAvatar: DAOPersistedUserAvatar = {
        return DAOPersistedUserAvatarImpl(persistenceDatabaseHelper: persistenceDatabaseHelper)
    }()
    private lazy var daoLanguage: DAOLanguageImpl = {
        return DAOLanguageImpl(dataRepository: dataRepository,
                               secondarySaverDataRepository: appGroupsDataRepository)
    }()
    private lazy var persistenceDataSource: PersistenceDataSource = {
        return LocalPersistenceDataSource(
            daoPersistedUser: daoPersistedUser,
            daoSharedPersistedUser: daoSharedPersistedUser,
            daoUserPref: daoUserPref,
            daoUserPrefEntity: daoUserPrefEntity,
            daoSharedUserPrefEntity: daoSharedUserPrefEntity,
            daoPublicFilesEnvironment: daoPublicFilesEnvironment,
            daoInbentaEnvironment: daoInbentaEnvironment,
            daoPersistedUserAvatar: daoPersistedUserAvatar,
            daoLanguage: daoLanguage
        )
    }()
    private lazy var inbentaHostProvider: InbentaHostProvider = {
        return hostModule.providesInbentaHostProvider()
    }()
    private lazy var publicFilesHostProvider: PublicFilesHostProviderProtocol = {
        return hostModule.providesPublicFilesHostProvider()
    }()
    private lazy var appRepository: AppRepository = {
        return AppRepositoryImpl(
            dependencies: self.dependenciesEngine,
            persistenceDataSource: self.persistenceDataSource,
            dataRepository: self.dataRepository,
            inbentaHostProvider: self.inbentaHostProvider,
            publicFilesHostProvider: self.publicFilesHostProvider)
    }()
    private lazy var downloadsRepository: DownloadsRepository = {
        return DownloadsRepositoryBuilder(dependenciesResolver: self.dependenciesEngine,
                                          appRepository: self.appRepository).build()
    }()
    private lazy var appGroupsDataRepository: DataRepository = {
        return AppGroupsDataRepositoryBuilder(dependenciesResolver: self.dependenciesEngine,
                                              appInfo: versionInfo).build()
    }()
    private lazy var pullOffersRepository: PullOffersRepositoryProtocol = {
        let repository: PullOffersRepositoryProtocol = coreDependenciesResolver.resolve()
        return repository
    }()
    private lazy var documentsRepository: DocumentsRepository = {
        let persistance = DownloadsPersistanceDataSourceImpl(pdfCache: AppDocumentsCacheImpl(absolutePath: NSTemporaryDirectory()))
        return DocumentsRepositoryImp(persistanceDataSource: persistance)
    }()
    private lazy var secondaryUseCaseHandler: SecondaryUseCaseHandler = {
        return SecondaryUseCaseHandler(main: mainUseCaseHandler, maxConcurrentOperationCount: 4, qualityOfService: .background)
    }()
    lazy var useCaseProvider: UseCaseProvider = {
        let bsanManagersProvider: BSANManagersProvider = self.dependenciesEngine.resolve(for: BSANManagersProvider.self)
        let bsanDataProvider: BSANDataProviderProtocol = self.dependenciesEngine.resolve(for: BSANDataProviderProtocol.self)
        return UseCaseProviderBuilder(
            versionInfo: versionInfo,
            appRepository: appRepository,
            bsanManagersProvider: bsanManagersProvider,
            pullOffersRepository: pullOffersRepository,
            pullOffersEngine: pullOffersEngine,
            downloadsRepository: downloadsRepository,
            appGroupsDataRepository: appGroupsDataRepository,
            documentsRepository: documentsRepository,
            dataRepository: dataRepository,
            dependenciesEngine: dependenciesEngine,
            trusteerRepository: trusteerRepository,
            bsanDataProvider: bsanDataProvider,
            coreDependenciesResolver: coreDependenciesResolver)
            .build()
    }()
    public lazy var trackerManager: TrackerManager = {
        return TrackerManagerImpl(usecaseProvider: useCaseProvider, usecaseHandler: secondaryUseCaseHandler)
    }()
    private lazy var safetyView: SafetyCurtain = {
        return SafetyCurtain(sessionManager: sessionManager, appEventsNotifier: appEventsNotifier)
    }()
    private lazy var presenterProvider: PresenterProvider = {
        return PresenterProvider(
            sessionManager: sessionManager,
            localAuthentication: localAuthentication,
            appEventsNotifier: appEventsNotifier,
            dependenciesEngine: dependenciesEngine)
    }()
    private lazy var imageLoader: ImageLoader = {
        return ImageManager(appRepository: appRepository)
    }()
    private lazy var inbentaManager: InbentaManager = {
        return InbentaManager(
            useCaseHandler: mainUseCaseHandler,
            useCaseProvider: useCaseProvider,
            stringLoader: stringLoader)
    }()
    private lazy var pullOfferActionsManager: PullOfferActionsManager = {
        return PullOfferActionsManager(
            useCaseHandler: mainUseCaseHandler,
            useCaseProvider: useCaseProvider,
            stringLoader: stringLoader)
    }()
    lazy var deepLinkManager: DeepLinkManager = {
        return  DeepLinkManager(sessionManager: sessionManager)
    }()
    private lazy var siriIntentsManager: SiriIntentsManager = {
        let siriHandler = self.dependenciesEngine.resolve(for: SiriAssistantProtocol.self)
        return SiriIntentsManager(deeplinkManager: deepLinkManager, siriHandler: siriHandler)
    }()
    lazy var userActivityManager: UserActivityManager = {
        return UserActivityManager(handlers: [deepLinkManager, siriIntentsManager])
    }()
    lazy var publicFilesManager: PublicFilesManagerProtocol = {
        let publicFilesManager = PublicFilesManager(
            useCaseProvider: useCaseProvider,
            useCaseHandler: mainUseCaseHandler,
            secondayUseCaseHandler: secondaryUseCaseHandler)
        publicFilesManager.add(subscriptor: SharedDependencies.self) { [weak self] in
            self?.publicFilesLoadingDidFinish()
        }
        return publicFilesManager
    }()
    private lazy var managerWallManager: ManagerWallManager = {
        return ManagerWallManager(useCaseHandler: mainUseCaseHandler, useCaseProvider: useCaseProvider)
    }()
    private lazy var sessionManager: CoreSessionManager = {
        return DefaultSessionManager(dependenciesResolver: self.dependenciesEngine)
    }()
    private lazy var localAuthentication: LocalAuthenticationPermissionsManagerProtocol = {
        return self.dependenciesEngine.resolve(for: PermissionsStatusWrapperProtocol.self).getLocalAuthenticationPermissionsManagerProtocol()
    }()
    private lazy var globalPositionModuleCoordinator: GlobalPositionModuleCoordinator = {
        return GlobalPositionModuleCoordinator(resolver: self.dependenciesEngine)
    }()
    private lazy var localeManager: LocaleManager = {
        return LocaleManager(dependencies: dependenciesEngine)
    }()
    
    init(dependenciesEngine: DependenciesResolver & DependenciesInjector, coreDependenciesResolver: RetailLegacyExternalDependenciesResolver, cardExternalDependenciesResolver: CardExternalDependenciesResolver) {
        self.dependenciesEngine = dependenciesEngine        
        self.dataRepository = dependenciesEngine.resolve(for: DataRepository.self)
        self.localAppConfig = dependenciesEngine.resolve(for: LocalAppConfig.self)
        self.trusteerRepository = dependenciesEngine.resolve(for: TrusteerRepositoryProtocol.self)
        self.versionInfo = dependenciesEngine.resolve(for: VersionInfoDTO.self)
        self.coreDependenciesResolver = coreDependenciesResolver
        self.cardExternalDependenciesResolver = cardExternalDependenciesResolver
        self.registerDependencies(injector: dependenciesEngine)
        self.configureIQKeyboard()
        self.configureToast()
        self.configureLogger()
        self.configureGlobals()
        self.safetyView.setup()
    }
}

private extension SharedDependencies {
    func configureIQKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
    }
    
    func configureToast() {
        Toast.timeLapse = 3.0
        Toast.font = .latoBold(size: 14.0)
        Toast.textColor = .uiWhite
        Toast.toastColor = .gray
        Toast.toastAlpha = 00.9
        Toast.enable()
    }
    
    func configureLogger() {
        let compilation = self.dependenciesEngine.resolve(for: CompilationProtocol.self)
        if compilation.isLogEnabled {
            RetailLogger.setRetailLogger(Logger(isLogEnabled: compilation.isLogEnabled))
            DataLogger.setDataLogger(Logger(isLogEnabled: compilation.isLogEnabled))
            BSANLogger.setBSANLogger(Logger(isLogEnabled: compilation.isLogEnabled))
        }
    }
    
    func configureGlobals() {
        self.configureLocalization()
        self.configureNumberFormatter()
        self.configureFontsHandler()
        self.configureStyles()
        self.configureTimeManagerGlobal()
        self.configureLocaleProvider()
    }
    
    func configureLocalization() {
        Localized.shared.setup(dependenciesResolver: dependenciesEngine)
    }
    
    func configureNumberFormatter() {
        NumberFormattingHandler.shared.setup(dependenciesResolver: dependenciesEngine)
    }
    
    func configureFontsHandler() {
        FontsHandler.setup(dependenciesResolver: dependenciesEngine)
    }
    
    func configureStyles() {
        ApplyStyles.shared.setup(dependenciesResolver: dependenciesEngine)
    }
    
    func configureTimeManagerGlobal() {
        TimeManagerGlobal.shared.setup(dependenciesResolver: dependenciesEngine)
    }
    
    func configureLocaleProvider() {
        LocaleProvider.shared.setup(dependenciesResolver: dependenciesEngine)
    }
    
    func registerDependencies(injector: DependenciesInjector) {
        injector.register(for: UseCaseHandler.self) { _ in
            return self.mainUseCaseHandler
        }
        injector.register(for: PullOffersInterpreter.self) { _ in
            return self.useCaseProvider.pullOffersInterpreter
        }
        injector.register(for: TrackerManager.self) { _ in
            return TrackerManagerImpl(usecaseProvider: self.useCaseProvider, usecaseHandler: self.secondaryUseCaseHandler)
        }
        injector.register(for: StringLoader.self) { _ in
            return self.stringLoader
        }
        injector.register(for: StringLoaderReactive.self) { _ in
            return self.stringLoader
        }
        injector.register(for: StylesLoader.self) { _ in
            return self.stylesManager
        }
        injector.register(for: TimeManager.self) { _ in
            return self.timeManager
        }
        injector.register(for: GlobalPositionRepresentable.self) { resolver in
            let provider: BSANManagersProvider = resolver.resolve(for: BSANManagersProvider.self)
            let globalPosition = GlobalPositionWrapperFactory.getEntity(bsanManagersProvider: provider)
            return globalPosition
        }
        injector.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
            return merger
        }
        injector.register(for: BaseURLProvider.self) { _ in
            let url = try? self.appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase ?? ""
            return BaseURLProvider(baseURL: url)
        }
        injector.register(for: GlobalPositionModuleCoordinator.self) { _ in
            return self.globalPositionModuleCoordinator
        }
        injector.register(for: NavigatorProvider.self) { _ in
            return self.navigatorProvider
        }
        injector.register(for: CoreSessionManager.self) { _ in
            return self.sessionManager
        }
        injector.register(for: SessionResponseController.self) { _ in
            return self
        }
        injector.register(for: GetLanguagesSelectionUseCaseProtocol.self) { resolver in
            return GetLanguagesSelectionUseCase(dependencies: resolver)
        }
        injector.register(for: CleanSessionUseCaseProtocol.self) { resolver in
            return CleanSessionUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GlobalPositionConfiguration.self) { _ in
            let isInsuranceBalanceEnabled = self.useCaseProvider.appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigInsuranceBalanceEnabled) ?? false
            let isCounterValueEnabled = self.useCaseProvider.appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigCounterValueEnabled) ?? false
            return GlobalPositionConfiguration(isInsuranceBalanceEnabled: isInsuranceBalanceEnabled, isCounterValueEnabled: isCounterValueEnabled)
        }
        injector.register(for: [AccountDescriptorEntity].self) { _ in
            return self.useCaseProvider.accountDescriptorRepository.get()?.accountsArray.map({ AccountDescriptorEntity(type: $0.type ?? "", subType: $0.subType ?? "") }) ?? []
        }
        injector.register(for: [AccountGroupEntity].self) { _ in
            return self.useCaseProvider.accountDescriptorRepository.get()?.accountGroupEntities.map({ AccountGroupEntity(code: $0.entityCode ?? "") }) ?? []
        }
        injector.register(for: [CardTextColorEntity].self) { _ in
            let cc = self.useCaseProvider.accountDescriptorRepository.get()?.cardsTextColor
            return cc?.compactMap({ CardTextColorEntity(cardCode: $0.cardCode) }) ?? []
        }
        injector.register(for: GlobalPositionReloadEngine.self) { _ in
            return self.globalPositionReloadEngine
        }
        injector.register(for: AppRepositoryProtocol.self) { _ in
            return self.useCaseProvider.appRepository
        }
        injector.register(for: AppConfigRepositoryProtocol.self) { _ in
            return self.useCaseProvider.appConfigRepository
        }
        injector.register(for: AppInfoRepositoryProtocol.self) { _ in
            return self.useCaseProvider.appInfoRepository
        }
        injector.register(for: SegmentedUserRepository.self) { _ in
            return self.useCaseProvider.segmentedUserRepository
        }
        injector.register(for: AccountDescriptorRepositoryProtocol.self) { _ in
            return self.useCaseProvider.accountDescriptorRepository
        }
        injector.register(for: LocationPermissionsManagerProtocol.self) { _ in
            return self.locationManager
        }
        injector.register(for: LocalAuthenticationPermissionsManagerProtocol.self) { _ in
            return self.localAuthentication
        }
        injector.register(for: GlobalPositionReloader.self) { _ in
            return self
        }
        injector.register(for: FaqsRepositoryProtocol.self) { _ in
            return self.useCaseProvider.faqsRepository
        }
        injector.register(for: PublicProductsRepositoryProtocol.self) { _ in
            return self.useCaseProvider.publicProductsRepository
        }
        injector.register(for: SepaInfoRepositoryProtocol.self) { _ in
            return self.useCaseProvider.sepaInfoRepository
        }
        injector.register(for: LoadingTipsRepositoryProtocol.self) { _ in
            return self.useCaseProvider.loadingTipsRepository
        }
        injector.register(for: CountriesRepositoryProtocol.self) { _ in
            return self.useCaseProvider.countriesRepository
        }
        injector.register(for: SearchKeywordsRepositoryProtocol.self) { _ in
            return self.useCaseProvider.searchKeywordRepository
        }
        injector.register(for: ManagerHobbiesRepositoryProtocol.self) { _ in
            return self.useCaseProvider.managerHobbiesRepository
        }
        injector.register(for: PullOffersConfigRepositoryProtocol.self) { _ in
            return self.useCaseProvider.pullOffersConfigRepository
        }
        injector.register(for: GetLoadingTipsUseCase.self) { _ in
            return self.useCaseProvider.getLoadingTipsUseCase()
        }

        injector.register(for: MerchantRepositoryProtocol.self) { _ in
            return self.useCaseProvider.merchantRepository
        }
        injector.register(for: ComingFeaturesRepositoryProtocol.self) { _ in
            return self.useCaseProvider.comingFeaturesRepository
        }
        injector.register(for: FrequentEmittersRepositoryProtocol.self) { _ in
            return self.useCaseProvider.frequentEmittersRepository
        }
        injector.register(for: BackgroundImageManagerProtocol.self) { _ in
            let backgroundImageManager: BackgroundImageManager = BackgroundImageManager()
            backgroundImageManager.setup(injector)
            return backgroundImageManager
        }
        injector.register(for: GenericErrorDialogCoordinatorDelegate.self) { _ in
            return self.navigatorProvider.privateHomeNavigator
        }
        injector.register(for: MenuModuleCoordinator.self) { dependenciesResolver in
            return MenuModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: self.navigatorProvider.drawer.currentSideMenuViewController as? UINavigationController ?? UINavigationController())
        }
        injector.register(for: DeepLinkManagerProtocol.self) { _ in
            return self.deepLinkManager
        }
        injector.register(for: ColorsByNameEngine.self) { _ in
            return self.colorsByNameEngine
        }
        injector.register(for: ContactsEngineProtocol.self) { _ in
            return self.contactsEngine
        }
        injector.register(for: ContactPermissionsManagerProtocol.self) { _ in
            return self.contactsManager
        }
        injector.register(for: TricksRepositoryProtocol.self) { _ in
            return self.useCaseProvider.tricksRepository
        }
        injector.register(for: EngineInterface.self) { _ in
            return self.pullOffersEngine
        }
        injector.register(for: UseCaseScheduler.self) { resolver in
            return resolver.resolve(for: UseCaseHandler.self)
        }
        injector.register(for: PullOffersRepositoryProtocol.self) { _ in
            return self.pullOffersRepository
        }
        injector.register(for: PublicFilesManagerProtocol.self) { _ in
            return self.publicFilesManager
        }
        injector.register(for: AppEventsNotifierProtocol.self) { _ in
            return self.appEventsNotifier
        }
        injector.register(for: SiriIntentsManagerProtocol.self) {_ in
            return self.siriIntentsManager
        }
        injector.register(for: EasyPayNavigatorProviderProtocol.self) { _ in
            return self.navigatorProvider
        }
        injector.register(for: ApplePayEnrollmentManagerProtocol.self) { resolver in
            return ApplePayEnrollmentManager(dependenciesResolver: resolver)
        }
        injector.register(for: PermissionsStatusWrapperProtocol.self) { resolver in
            return PermissionsStatusWrapper(dependencies: resolver)
        }
        injector.register(for: BizumDefaultNGOsRepositoryProtocol.self) { _ in
            return self.useCaseProvider.bizumDefaultNGOsRepository
        }
        injector.register(for: OfferCoordinatorLauncher.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: ModuleCoordinatorNavigator.self)
        }
        injector.register(for: PDFCoordinatorLauncher.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: ModuleCoordinatorNavigator.self)
        }
        injector.register(for: NextSettlementLauncher.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: ModuleCoordinatorNavigator.self)
        }
        injector.register(for: DeeplinksCoordinatorLauncher.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: ModuleCoordinatorNavigator.self)
        }
        injector.register(for: CoordinatorViewControllerProvider.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: ModuleCoordinatorNavigator.self)
        }
        injector.register(for: BaseWebViewNavigatableLauncher.self) { _ in
            return self.navigatorProvider.privateHomeNavigator
        }
        injector.register(for: PrivateHomeNavigatorLauncher.self) { _ in
            return self.navigatorProvider.privateHomeNavigator
        }
        injector.register(for: OperativeCoordinatorLauncher.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: ModuleCoordinatorNavigator.self)
        }
        injector.register(for: VirtualAssistantCoordinatorLauncher.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: ModuleCoordinatorNavigator.self)
        }
        injector.register(for: OpinatorCoordinatorLauncher.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: ModuleCoordinatorNavigator.self)
        }
        injector.register(for: CardsHomeModuleCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        injector.register(for: TealiumRepository.self) { resolver in
            return self.useCaseProvider.tealiumRepository
        }
        injector.register(for: NetInsightRepository.self) { resolver in
            return NetInsightRepositoryImpl(networkService: NetworkServiceImpl(callExecutor: NetworkURLSessionExecutor(dependenciesResolver: resolver)))
        }
        injector.register(for: SessionManagerDelegate.self) { _ in
            return self
        }
        injector.register(for: RefreshSessionUseCase.self) { resolver in
            return DefaultRefreshSessionUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: LogoutUseCase.self) { resolver in
            return DefaultLogoutUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetLocalPushTokenUseCase.self) { dependenciesResolver in
            return GetLocalPushTokenUseCase(dependenciesResolver: dependenciesResolver)
        }
        injector.register(for: PersistenceDataSource.self) { dependenciesResolver in
            return self.persistenceDataSource
        }
        injector.register(for: RetailLegacyExternalDependenciesResolver.self) { _ in
            return self.coreDependenciesResolver
        }
        injector.register(for: FractionedPaymentsLauncher.self) { _ in
            return self.navigatorProvider.getModuleCoordinator(type: ModuleCoordinatorNavigator.self)
        }
        injector.register(for: CardsTransactionDetailModuleCoordinatorDelegate.self) { resolve in
            let navigationController = self.navigatorProvider.drawer.currentRootViewController as? UINavigationController ?? UINavigationController()
            return CardsHomeModuleCoordinator(
                dependenciesResolver: resolve,
                navigationController: navigationController,
                externalDependencies: self.cardExternalDependenciesResolver
            )
        }
        injector.register(for: BooleanFeatureFlag.self) { _ in
            let booleanFeatureFlag: BooleanFeatureFlag = self.coreDependenciesResolver.resolve()
            return booleanFeatureFlag
        }
    }
    
    func publicFilesLoadingDidFinish() {
        let delegate: SharedDependenciesDelegate = self.dependenciesEngine.resolve(for: SharedDependenciesDelegate.self)
        delegate.publicFilesFinished(self.useCaseProvider.appConfigRepository)
    }
}

extension SharedDependencies: GlobalPositionReloader {
    public func reloadGlobalPosition() {
        let loadingText = LoadingText(title: stringLoader.getString("generic_popup_loading"), subtitle: stringLoader.getString("loading_label_moment"))
        LoadingCreator.showGlobalLoading(loadingText: loadingText, controller: currentRootController) { [weak self] in
            self?.sessionProcessHelperDelegate.view = self?.currentRootController
            self?.sessionDataManager.load()
        }
    }
    
    var currentRootController: UIViewController {
        let drawer = navigatorProvider.drawer
        guard let currentRootViewController = drawer.currentRootViewController as? UINavigationController,
            let navigtionPresented = currentRootViewController.topViewController?.presentedViewController as? UINavigationController else {
                return drawer
        }
        return navigtionPresented
    }
}

extension SharedDependencies: SessionResponseController {
    func recivenUnauthorizedResponse() {
        sessionManager.finishWithReason(.notAuthorized)
    }

    func recivedLockedAccessMethodResponse() {
        sessionManager.finishWithReason(.logOut)
    }
}

extension SharedDependencies: SessionManagerDelegate {
    public func didFinishSession() {
        checkPersistedUser()
            .execute(on: dependenciesEngine.resolve())
            .onSuccess({ [weak self] _ in
                self?.didFinishSessionWithPersisteduser(true)
            })
            .onError { [weak self] _ in
                self?.didFinishSessionWithPersisteduser(false)
            }
    }
    
    func didFinishSessionWithPersisteduser(_ persistedUser: Bool) {
        presenterProvider.dependencies.secondaryUseCaseHandler.stopAll()
        navigatorProvider.resetCoordinators()
        navigatorProvider.sessionNavigator.removeModals()
        navigatorProvider.sessionNavigator.goToPublic(shouldGoToRememberedLogin: persistedUser)
    }
    
    func checkPersistedUser() -> Scenario<Void, Void, CheckPersistedUserUseCaseErrorOutput> {
        return Scenario(useCase: useCaseProvider.getCheckPersistedUserUseCase())
    }
}
