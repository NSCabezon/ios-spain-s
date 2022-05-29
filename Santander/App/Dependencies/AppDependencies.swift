//
//  AppDependencies.swift
//  RetailLegacy_Example
//
//  Created by Juan Carlos López Robles on 1/4/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CoreFoundationLib
import Foundation
import SANLibraryV3
import RetailLegacy
import ESCommons
import SANLegacyLibrary
import PersonalArea
import CorePushNotificationsService
import Bizum
import Cards
import Account
import Transfer
import Inbox
import InboxNotification
import SANServicesLibrary
import SANSpainLibrary
import Login
import CoreDomain
import GlobalPosition
import SantanderKey
import Menu

final class AppDependencies {
    #if DEBUG
    private let timeToRefreshToken: TimeInterval = 10000000000000
    private let timeToExpireSession: TimeInterval = 10000000000000
    #else
    private let timeToRefreshToken: TimeInterval = 60 * 8
    private let timeToExpireSession: TimeInterval = 60 * 9
    #endif
    private let hostModule = HostModule()
    private let compilation = Compilation()
    private let localAppConfig: LocalAppConfig = SpainAppConfig()
    private let appModifiers: AppModifiers
    // swiftlint:disable force_cast
    private let versionInfo = VersionInfoDTO(
        bundleIdentifier: Bundle.main.bundleIdentifier!,
        versionName: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    )
    // swiftlint:enable force_cast
    private lazy var notificationManagerBridge: APPNotificationManagerBridgeProtocol = {
        return NotificationManagerBridge(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var salesforceService: SPSalesForceHandlerProtocol = {
       return SalesforceHandlerSP(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var twinpush = TwinpushHandler(dependenciesResolver: self.dependencieEngine)
    private lazy var twinpushService: TwinpushHandlerProtocol = {
        return self.twinpush
    }()
    private lazy var customPushLauncher: CustomPushLauncherProtocol = {
        return SpainPushLauncher(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var notificationDeviceInfoProvider: NotificationDeviceInfoProvider = {
        return self.twinpush
    }()
    private lazy var notificationPermissionsManager: NotificationPermissionsManager = {
        return NotificationPermissionsManager(dependencies: self.dependencieEngine)
    }()
    private lazy var siriIntentsManager: SiriIntentsManagerHandler = {
        return SiriIntentsManagerHandler()
    }()
    private lazy var dataRepository: DataRepository = {
        return DataRepositoryBuilder(dependenciesResolver: dependencieEngine).build()
    }()
    private lazy var bsanManagersProvider: SANLibraryV3.BSANManagersProvider = {
        return BSANManagersProviderBuilder(dependenciesResolver: self.dependencieEngine).build()
    }()
    private lazy var bsanDataProvider: BSANDataProviderProtocol = {
        return BSANDataProvider(dataRepository: dataRepository, appInfo: versionInfo)
    }()
    private lazy var webServicesUrlProvider: WebServicesUrlProvider = {
        let bsanDataProvider = self.dependencieEngine.resolve(for: BSANDataProvider.self)
        return WebServicesUrlProviderImpl(bsanDataProvider: bsanDataProvider)
    }()
    private lazy var tealiumCompilation: TealiumCompilationProtocol = {
        return TealiumCompilation()
    }()
    private lazy var personalAreaSections: PersonalAreaSectionsProvider = {
        return PersonalAreaSectionsProvider(dependenciesResolver: dependencieEngine)
    }()
    private lazy var securityAreaSectionsProvider: SecurityAreaSectionsProvider = {
        return SecurityAreaSectionsProvider(dependenciesResolver: dependencieEngine)
    }()
    private lazy var notificationManager: NotificationsManager = {
        return NotificationsManager(dependencies: self.dependencieEngine)
    }()
    private lazy var notificationHandler: NotificationsHandlerProtocol = {
        return self.notificationManager
    }()
    private lazy var pushNotificationsExecutor: PushNotificationsExecutorProtocol = {
        return self.notificationManager
    }()
    private lazy var pushNotificationsUserInfo: PushNotificationsUserInfo = {
        return self.notificationManager
    }()
    private lazy var coreNotificationsService: CorePushNotificationsManagerProtocol = {
        return CorePushNotificationsManager(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var getPGFrequentOperativeOption: GetPGFrequentOperativeOptionProtocol = {
        return GetPGFrequentOperativeOption(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var shortcutItemProvider: ShortcutItemsProviderProtocol = {
        return SpainShortcutItems()
    }()
    private lazy var servicesLibrary: ServicesLibrary = {
        return ServicesLibrary(networkClient: self.netClient, environment: Environment.pro, bsanManagersProvider: self.bsanManagersProvider, sessionStorage: servicesStorage)
    }()
    private lazy var servicesStorage: Storage = {
        return MemoryStorage()
    }()
    private lazy var netClient: DefaultNetworkClient = {
        return DefaultNetworkClient(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var inboxActionBuilderModifier: InboxActionBuilderModifierProtocol = {
        return InboxActionBuilderModifier(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var inboxHomeCoordinatorDelegate: InboxHomeCoordinatorDelegate = {
        return InboxActionBuilderModifier(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var bankingUtils: BankingUtilsProtocol = {
        return BankingUtils(dependencies: self.dependencieEngine)
    }()
    private lazy var sessionHandler: SessionHandler = {
       return SessionHandler(dependencieEngine: dependencieEngine)
    }()
    private lazy var defaultSessionDataManager: SessionDataManager = {
        return DefaultSessionDataManager(dependenciesResolver: dependencieEngine)
    }()
    private lazy var loginSessionStateHelper: LoginSessionStateHelper = {
        return LoginSessionStateHelper()
    }()
    private lazy var pfmTransactionsHandler: PFMTransactionsHandler = {
        return DefaultPFMTransactionsHandler(dependenciesResolver: dependencieEngine)
    }()
    private let pfmUseCaseHandler: UseCaseHandler = UseCaseHandler(maxConcurrentOperationCount: 6, qualityOfService: .utility)
    private lazy var pfmController: LoadPfmSuperUseCase = {
        return LoadPfmSuperUseCase(
            useCaseHandler: pfmUseCaseHandler,
            appConfigRepository: dependencieEngine.resolve(),
            dependenciesResolver: dependencieEngine
        )
    }()
    
    let dependencieEngine: DependenciesResolver & DependenciesDefault

    init() {
        self.dependencieEngine = DependenciesDefault()
        self.appModifiers = AppModifiers(dependenciesEngine: dependencieEngine)
        self.registerDependencies()
        self.salesforceService.start()
        self.twinpushService.start()
    }

    func getDependenciesResolver() -> DependenciesResolver {
        return self.dependencieEngine
    }
}

private extension AppDependencies {
    func registerDependencies() {
        self.dependencieEngine.register(for: SpainCompilationProtocol.self) { _ in
            return self.compilation
        }
        self.dependencieEngine.register(for: CompilationProtocol.self) { _ in
            return self.compilation
        }
        self.dependencieEngine.register(for: VersionInfoDTO.self) { _ in
            return self.versionInfo
        }
        self.dependencieEngine.register(for: HostsModuleProtocol.self) { _ in
            return self.hostModule
        }
        self.dependencieEngine.register(for: DataRepository.self) { _ in
            return self.dataRepository
        }
        self.dependencieEngine.register(for: BSANDataProvider.self) { _ in
            return BSANDataProvider(dataRepository: self.dataRepository, appInfo: self.versionInfo)
        }
        self.dependencieEngine.register(for: "ServicesStorage", type: Storage.self) { _ in
            return self.servicesStorage
        }
        self.dependencieEngine.register(for: WebServicesUrlProvider.self) { _ in
            return self.webServicesUrlProvider
        }
        self.dependencieEngine.register(for: TargetProviderProtocol.self) { resolver in
            return TargetProvider(
                webServicesUrlProvider: resolver.resolve(),
                bsanDataProvider: resolver.resolve(),
                compilation: resolver.resolve()
            )
        }
        self.dependencieEngine.register(for: DemoInterpreterProtocol.self) { resolver in
            return resolver.resolve(for: TargetProviderProtocol.self).getDemoInterpreter()
        }
        self.dependencieEngine.register(for: EmmaTrackEventListProtocol.self) { _ in
            return EmmaTrackEventList()
        }
        self.dependencieEngine.register(for: NotificationsHandlerProtocol.self) { _ in
            self.notificationHandler.addService(self.salesforceService)
            self.notificationHandler.addService(self.twinpushService)
            return self.notificationHandler
        }
        self.dependencieEngine.register(for: InboxMessagesManager.self) { _ in
            return self.salesforceService
        }
        self.dependencieEngine.register(for: APPNotificationManagerBridgeProtocol.self) { _ in
            return self.notificationManagerBridge
        }
        self.dependencieEngine.register(for: CorePushNotificationsManagerProtocol.self) { _ in
            return self.coreNotificationsService
        }
        self.dependencieEngine.register(for: PushNotificationPermissionsManagerProtocol.self) { _ in
            return self.notificationPermissionsManager
        }
        self.dependencieEngine.register(for: TrusteerRepositoryProtocol.self) { _ in
            return RAHandler.sharedInstance
        }
        self.dependencieEngine.register(for: SiriAssistantProtocol.self) { _ in
            return self.siriIntentsManager
        }
        self.dependencieEngine.register(for: LocalAppConfig.self) { _ in
            return self.localAppConfig
        }
        self.dependencieEngine.register(for: BSANManagersProvider.self) { _ in
            return self.bsanManagersProvider
        }
        self.dependencieEngine.register(for: BSANDataProviderProtocol.self) { _ in
            return self.bsanDataProvider
        }
        self.dependencieEngine.register(for: SharedDependenciesDelegate.self) { _ in
            return self
        }
        self.dependencieEngine.register(for: TealiumCompilationProtocol.self) { _ in
            return self.tealiumCompilation
        }
        self.dependencieEngine.register(for: PersonalAreaSectionsProtocol.self) { _ in
            return self.personalAreaSections
        }
        self.dependencieEngine.register(for: SecurityAreaActionProtocol.self) { _ in
            return self.securityAreaSectionsProvider
        }
        self.dependencieEngine.register(for: GetPGFrequentOperativeOptionProtocol.self) { _ in
            return self.getPGFrequentOperativeOption
        }
        self.dependencieEngine.register(for: ShortcutItemsProviderProtocol.self) { _ in
            return self.shortcutItemProvider
        }
        self.dependencieEngine.register(for: CorePushNavigatorProviderDelegate.self) { _ in
            return self.dependencieEngine.resolve(for: NavigatorProvider.self)
        }
        self.dependencieEngine.register(for: InboxNotificationCoordinatorDelegate.self) { resolver in
            return InboxNotificationCoordinator(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: CustomPushLauncherProtocol.self) { _ in
            return self.customPushLauncher
        }
        self.dependencieEngine.register(for: InboxActionBuilderModifierProtocol.self) { _ in
            return self.inboxActionBuilderModifier
        }
        self.dependencieEngine.register(for: InboxHomeCoordinatorDelegate.self) { _ in
            return self.inboxHomeCoordinatorDelegate
        }
        self.dependencieEngine.register(for: NotificationDeviceInfoProvider.self) { _ in
            return self.notificationDeviceInfoProvider
        }
        self.dependencieEngine.register(for: PushNotificationsUserInfo.self) { _ in
            return self.pushNotificationsUserInfo
        }
        self.dependencieEngine.register(for: PushNotificationsExecutorProtocol.self) { _ in
            return self.pushNotificationsExecutor
        }
        self.dependencieEngine.register(for: BankingUtilsProtocol.self) { _ in
            return self.bankingUtils
        }
        self.dependencieEngine.register(for: SessionDataManager.self) { _ in
            return self.defaultSessionDataManager
        }
        self.dependencieEngine.register(for: SessionDataManagerModifier.self) { _ in
            return self.sessionHandler
        }
        self.dependencieEngine.register(for: LoginSessionStateHelper.self) { _ in
            return self.loginSessionStateHelper
        }
        self.dependencieEngine.register(for: SessionConfiguration.self) { resolver in
            let loadPfm = LoadPfmSessionStartedAction(dependenciesResolver: resolver)
            let stopPfm = StopPfmSessionFinishedAction(dependenciesResolver: resolver)
            return SessionConfiguration(timeToExpireSession: self.timeToExpireSession,
                                        timeToRefreshToken: self.timeToRefreshToken,
                                        sessionStartedActions: [loadPfm],
                                        sessionFinishedActions: [stopPfm])
        }
        self.dependencieEngine.register(for: ForcedPasswordChangeAdapterProtocol.self) { resolver in
            return ForcedPasswordChangeAdapter(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: AppStoreInformationUseCase.self) { _ in
            return SpainAppStoreInformationUseCase()
        }
        self.dependencieEngine.register(for: ProductAliasManagerProtocol.self) { _ in
            return SPChangeAliasManager()
        }
       
        self.registerServicesLibraryDependencies()
        self.registerGetAllTransfersUseCases()
        self.registerPFMDependencies()
        self.registerAccountsDependencies()
        self.registerCardsDependencies()
    }
    
    func registerAccountsDependencies() {
        self.dependencieEngine.register(for: GetAccountTransactionsUseCaseProtocol.self) { dependenciesResolver in
            return SpainGetAccountTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencieEngine.register(for: SetReadAccountTransactionsUseCase.self) { dependenciesResolver in
            return SetReadAccountTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencieEngine.register(for: SetReadCardTransactionsUseCase.self) { dependenciesResolver in
            return SetReadCardTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencieEngine.register(for: GetAssociatedAccountTransactionsUseCase.self) { dependenciesResolver in
            return SpainGetAssociatedAccountTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencieEngine.register(for: GetUnreadMovementsUseCase.self) { resolver in
            return SpainGetUnreadMovementsUseCase(dependenciesResolver: resolver)
		}
        self.dependencieEngine.register(for: GetIsEnabledFinancialHealthUseCase.self) { dependenciesResolver in
            return GetIsEnabledFinancialHealthUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencieEngine.register(for: GetCardFinanceableTransactionsUseCase.self) { dependenciesResolver in
            return SpainGetCardFinanceableTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencieEngine.register(for: GetCreditCardUseCase.self) { dependenciesResolver in
            return SpainGetCreditCardUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependencieEngine.register(for: GetCardsExpensesCalculationUseCase.self) { dependenciesResolver in
            return SpainGetCardsExpensesCalculationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.registerServicesLibraryDependencies()
        self.registerGetAllTransfersUseCases()
        self.registerPFMDependencies()
    }
    
    func registerCardsDependencies() {
        self.dependencieEngine.register(for: PreSetupEasyPayUseCase.self) { resolver in
            return SpainPreSetupEasyPayUseCase(dependenciesResolver: resolver)
        }
    }
    
    func registerPFMDependencies() {
        self.dependencieEngine.register(for: CalculatePfmUseCase.self) { _ in
            return CalculatePfmUseCase()
        }
        self.dependencieEngine.register(for: GetGlobalPositionUseCaseAlias.self) { resolver in
            return GetGlobalPositionUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: GetAllCardTransactionsUseCase.self) { resolver in
            return GetAllCardTransactionsUseCase(managersProvider: resolver.resolve())
        }
        self.dependencieEngine.register(for: GetAllAccountTransactionsUseCase.self) { resolver in
            return GetAllAccountTransactionsUseCase(managersProvider: resolver.resolve())
        }
        self.dependencieEngine.register(for: PFMErrorResolverProtocol.self) { _ in
            return PFMErrorResolver()
        }
        self.dependencieEngine.register(for: GetMonthlyBalanceUseCase.self) { resolver in
            return GetPFMMonthlyBalanceUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: GetAccountUnreadMovementsUseCase.self) { resolver in
            return GetPFMAccountUnreadMovementsUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: GetCardUnreadMovementsUseCase.self) { resolver in
            return GetPFMCardUnreadMovementsUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: GetFilteredAccountTransactionsUseCaseProtocol.self) { dependenciesResolver in
            return GetAccountTransactionsPFMUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencieEngine.register(for: PFMTransactionsHandler.self) { _ in
            return self.pfmTransactionsHandler
        }
        self.dependencieEngine.register(for: PfmControllerProtocol.self) { _  in
            return self.pfmController
        }
        self.dependencieEngine.register(for: PfmHelperProtocol.self) { _  in
            return self.pfmController
        }
    }

    func registerServicesLibraryDependencies() {
        self.dependencieEngine.register(for: "NetworkDemoClient", type: NetworkClient.self) { _ in
            return DemoClient()
        }
        self.dependencieEngine.register(for: NetworkClient.self) { _ in
            return self.netClient
        }
        self.dependencieEngine.register(for: ClientsProvider.self) { _ in
            return self.servicesLibrary
        }
        self.dependencieEngine.register(for: BizumRepository.self) { _ in
            return self.servicesLibrary.bizumRepository
        }
        self.dependencieEngine.register(for: LoginRepository.self) { _ in
            return self.servicesLibrary.loginRepository
        }
        self.dependencieEngine.register(for: ConfigurationRepository.self) { _ in
            return self.servicesLibrary.configurationRepository
        }
        self.dependencieEngine.register(for: UserSessionRepository.self) { _ in
            return self.servicesLibrary.sessionRepository
        }
        self.dependencieEngine.register(for: EnvironmentProvider.self) { _ in
            return self.servicesLibrary
        }
        self.dependencieEngine.register(for: TransfersRepository.self) { _ in
            return self.servicesLibrary.transfersRepository
        }
        self.dependencieEngine.register(for: SpainTransfersRepository.self) { _ in
            return self.servicesLibrary.transfersRepository
        }
        self.dependencieEngine.register(for: SpainGlobalPositionRepository.self) { _ in
            return self.servicesLibrary.globalPositionRepository
        }
        self.dependencieEngine.register(for: AdobeTargetRepository.self) { _ in
            return self.servicesLibrary.adobeTargetRepository
        }
        self.dependencieEngine.register(for: CarbonFootprintRepository.self) { _ in
            return self.servicesLibrary.carbonFootprintRepository
        }
        self.dependencieEngine.register(for: SpainCarbonFootprintRepository.self) { _ in
            return self.servicesLibrary.carbonFootprintRepository
        }
        self.dependencieEngine.register(for: LoansRepository.self) { _ in
            return self.servicesLibrary.loansRepository
        }
        self.dependencieEngine.register(for: OnboardingRepository.self) { _ in
            return self.servicesLibrary.onboardingRepository
        }
        self.dependencieEngine.register(for: LoanReactiveRepository.self) { _ in
            return self.servicesLibrary.loanReactiveRepository
        }
        self.dependencieEngine.register(for: FundReactiveRepository.self) { _ in
            return self.servicesLibrary.fundReactiveRepository
        }
        self.dependencieEngine.register(for: CardRepository.self) { _ in
             return self.servicesLibrary.cardReactiveRepository
        }
        self.dependencieEngine.register(for: ConfirmDeleteFavouriteUseCaseProtocol.self) { resolver in
            return SpainConfirmDeleteFavouriteUseCase(dependencies: resolver)
        }
        
        self.dependencieEngine.register(for: PersonalManagerReactiveRepository.self) { _ in
            return self.servicesLibrary.personalManagerReactiveRepository
        }
        self.dependencieEngine.register(for: PersonalManagerNotificationReactiveRepository.self) { _ in
            return self.servicesLibrary.personalManagerManagerNotificationReactiveRepository
        }
        self.dependencieEngine.register(for: FinancialHealthRepository.self) { _ in
            return self.servicesLibrary.financialHealthRepository
        }
        self.dependencieEngine.register(for: UserSessionFinancialHealthRepository.self) { _ in
            return self.servicesLibrary.userSessionFinancialHealthRepository
        }
        self.dependencieEngine.register(for: SantanderKeyOnboardingRepository.self) { _ in
            return self.servicesLibrary.santanderKeyOnboardingRepository
        }
    }
    
    func registerGetAllTransfersUseCases() {
        self.dependencieEngine.register(for: GetReceivedTransfersUseCaseGroup<AllTransfersRetriever>.self) { resolver in
            return GetReceivedTransfersUseCaseGroup(dependenciesResolver: resolver, useCaseHandler: resolver.resolve())
        }
        self.dependencieEngine.register(for: GetEmittedTransferUseCaseGroup<AllTransfersRetriever>.self) { resolver in
            return GetEmittedTransferUseCaseGroup(dependenciesResolver: resolver, useCaseHandler: resolver.resolve())
        }
        self.dependencieEngine.register(for: GetAllTransfersUseCase.self) { resolver in
            return GetAllTransfersUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: GetEmittedTransfersUseCase.self) { resolver in
            return GetEmittedTransfersUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: GetReceivedTransfersUseCase.self) { resolver in
            return GetReceivedTransfersUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: GetAllTransfersUseCaseProtocol.self) { resolver in
            return GetAllTransfersUseCase(dependenciesResolver: resolver)
        }
    }
}

extension AppDependencies: SharedDependenciesDelegate {
    func publicFilesFinished(_ appConfigRepository: AppConfigRepositoryProtocol) {
        let otpServices = appConfigRepository.getAppConfigListNode(DomainConstant.appConfigManagerOTPServices) ?? []
        self.bsanManagersProvider.setServiceLanguage(otpServices)
        let mulMovUrls = appConfigRepository.getAppConfigListNode(DomainConstant.appConfigManagerMulMovUrls) ?? []
        var configurationRepository = self.dependencieEngine.resolve(for: ConfigurationRepository.self)
        configurationRepository[\.mulmovUrls] = mulMovUrls
        configurationRepository[\.appInfo] = dependencieEngine.resolve(for: VersionInfoDTO.self)
        configurationRepository[\.specialLanguageServiceNames] = otpServices
        self.webServicesUrlProvider.setUrlsForMulMov(mulMovUrls)
        let appConfigInsurancePASS2 = appConfigRepository.getBool(DomainConstant.appConfigInsurancePASS2) ?? false
        self.webServicesUrlProvider.setShouldUsePass2Urls(appConfigInsurancePASS2)
    }
}

extension VersionInfoDTO: AppInfoRepresentable {
    public var bundleIdentifier: String {
        return self.getBundleIdentifier()
    }
    
    public var versionName: String {
        return self.getVersionName()
    }
}
