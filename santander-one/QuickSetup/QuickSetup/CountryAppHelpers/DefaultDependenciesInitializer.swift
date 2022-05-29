import CoreFoundationLib
import CoreDomain
import Localization
import CoreTestData

public final class DefaultDependenciesInitializer {
    private let dependencies: DependenciesInjector & DependenciesResolver
    
    public init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
    }

    private var pullOffersEngine = BaseEngine()
    private var useCaseHandler = UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
    private lazy var globalPositionEngine = GlobalPositionReloadEngine()
    private lazy var localeManager: LocaleManager = {
        let locale = LocaleManager(dependencies: self.dependencies)
        locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        return locale
    }()
    private let userPreferencesRepositoryMock: UserPreferencesRepository = UserPreferencesRepositoryMock()

    public func registerDefaultDependencies() {
        self.dependencies.register(for: UseCaseHandler.self) { _ in
            return self.useCaseHandler
        }
        self.dependencies.register(for: UseCaseScheduler.self) { _ in
            return self.useCaseHandler
        }
        self.dependencies.register(for: PullOffersInterpreter.self) { _ in
            return PullOffersInterpreterMock()
        }
        self.dependencies.register(for: EngineInterface.self) { _ in
            return self.pullOffersEngine
        }
        self.dependencies.register(for: PfmControllerProtocol.self) { _ in
            return PFMControllerMock()
        }
        self.dependencies.register(for: PfmHelperProtocol.self) { _ in
            return PullOffersInterpreterMock()
        }
        self.dependencies.register(for: LocalAppConfig.self) { _ in
            return LocalAppConfigMock()
        }
        self.dependencies.register(for: LocalAuthenticationPermissionsManagerProtocol.self) { _ in
            return LocalAuthenticationPermissionsManagerMock()
        }
        self.dependencies.register(for: TealiumRepository.self) { _ in
            return AnalyticsRepositoryMock()
        }
        self.dependencies.register(for: NetInsightRepository.self) { _ in
            return AnalyticsRepositoryMock()
        }
        self.dependencies.register(for: MetricsRepository.self) { _ in
            return AnalyticsRepositoryMock()
        }
        self.dependencies.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        self.dependencies.register(for: TrackerManager.self) { _ in
            return TrackerManagerMock()
        }
        self.dependencies.register(for: TimeManager.self) { _ in
            return self.localeManager
        }
        self.dependencies.register(for: StringLoader.self) { _ in
            return self.localeManager
        }
        self.dependencies.register(for: BaseURLProvider.self) { _ in
            return BaseURLProvider(baseURL: "https://microsite.bancosantander.es/filesFF/")
        }
        self.dependencies.register(for: GlobalPositionReloadEngine.self) { _ in
            return self.globalPositionEngine
        }
        self.dependencies.register(for: EmmaTrackEventListProtocol.self) { _ in
            return EmmaTrackEventListMock()
        }
        self.dependencies.register(for: GetLanguagesSelectionUseCaseProtocol.self) { resolver in
            return GetLanguagesSelectionUseCase(dependencies: resolver)
        }
        self.dependencies.register(for: PushNotificationPermissionsManagerProtocol.self) { _ in
            return PushNotificationPermissionsManagerProtocolMock()
        }
        self.dependencies.register(for: CountriesRepositoryProtocol.self) { _ in
            return CountriesRepositoryProtocolMock()
        }
        self.dependencies.register(for: CompilationProtocol.self) { _ in
            return CompilationMock()
        }
        self.dependencies.register(for: ApplePayEnrollmentManagerProtocol.self) { _ in
            return ApplePayEnrollmentManagerProtocolMock()
        }
        self.dependencies.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            return GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: false)
        }
        self.dependencies.register(for: GetPullOffersUseCase.self) { resolver in
            return GetPullOffersUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: TrackerManager.self) { _ in
            return TrackerManagerMock()
        }
        self.dependencies.register(for: LocationPermission.self) { resolver in
            return LocationPermission(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: LocationPermissionsManagerProtocol.self) { _ in
            return LocationPermissionsManagerMock()
        }
        self.dependencies.register(for: LocalAuthenticationPermissionsManagerProtocol.self) { _ in
            return LocalAuthenticationPermissionsManagerMock()
        }
        self.dependencies.register(for: AccountDescriptorRepositoryProtocol.self) { _ in
            return AccountDescriptorRepositoryMock(netClient: NetClientMock(), assetsClient: AssetsClient(), fileClient: FileClient())
        }
        self.dependencies.register(for: GetLoadingTipsUseCase.self) { dependenciesResolver in
            return GetLoadingTipsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: FrequentEmittersRepositoryProtocol.self) { _ in
            return FrequentEmittersRepository()
        }
        self.dependencies.register(for: PublicFilesManagerProtocol.self) { _ in
            return PublicFilesManagerProtocolMock()
        }
        self.dependencies.register(for: SessionDataManager.self) { _ in
            return SessionDataManagerMock()
        }
        self.dependencies.register(for: CoreSessionManager.self) { _ in
            return CoreSessionManagerMock()
        }
        self.dependencies.register(for: SegmentedUserRepository.self) { _ in
            return SegmentedUserRepositoryProtocolMock()
        }
        self.dependencies.register(for: BackgroundImageRepositoryProtocol.self) { _ in
            return BackgroundImageRepositoryProtocolMock()
        }
        self.dependencies.register(for: DeleteBackgroundImageRepositoryProtocol.self) { _ in
            return DeleteBackgroundImageRepositoryProtocolMock()
        }
        self.dependencies.register(for: UserPreferencesRepository.self) { _ in
            return self.userPreferencesRepositoryMock
        }
        self.dependencies.register(for: PublicProductsRepositoryProtocol.self) { _ in
            return PublicProductsRepositoryMock()
        }
        Localized.shared.setup(dependenciesResolver: self.dependencies)
        TimeManagerGlobal.shared.setup(dependenciesResolver: self.dependencies)
    }
}   
