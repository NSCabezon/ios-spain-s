import UIKit
import QuickSetupES
import Bizum
import CoreFoundationLib
import SANLibraryV3
import Operative
import UI
import Contacts
import BiometryValidator
import SANSpainLibrary
import SANServicesLibrary
import Ecommerce
import ESCommons
import CorePushNotificationsService
import Localization
import CoreDomain
import QuickSetup

struct MockOperation: SplitableExpenseProtocol {
    var amount: AmountEntity
    var concept: String
    var productAlias: String
}

class ViewController: UIViewController {
    var navController = UINavigationController()
    var globalPosition: GlobalPositionRepresentable!
    let reloadEngine = GlobalPositionReloadEngine()
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        return QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadPG()
    }

    private lazy var servicesLibrary: ServicesLibrary = {
        return ServicesLibrary(networkClient: DefaultNetworkClient(dependenciesResolver: dependencies),
                               environment: Environment.pre,
                               bsanManagersProvider: BSANManagersProvider())
    }()

    private func loadPG() {
        quickSetup.setEnviroment(QuickSetupES.BSANEnvironments.enviromentPreWas9)
        quickSetup.doLogin(withUser: .demo)
        quickSetup.setDemoAnswers(["consultarDBasicos": 1])
        _ = try? quickSetup.managersProvider.getBsanSignatureManager().loadCMCSignature()
        self.globalPosition = quickSetup.getGlobalPosition()
    }
    
    private func registerDependenciesForHomeModule() {
        self.dependencies.register(for: BizumTypeUseCase.self, with: { (resolver: DependenciesResolver) -> BizumTypeUseCase in
            return BizumTypeUseCase(dependenciesResolver: resolver)
        })
    }
    private func performPublicFile() {
        let appConfigRepository = self.dependencies.resolve(for: AppConfigRepositoryProtocol.self)
        let mulMovUrls = appConfigRepository.getAppConfigListNode("mulMovUrls") ?? []
        var configurationRepository = self.dependencies.resolve(for: ConfigurationRepository.self)
        configurationRepository[\.mulmovUrls] = mulMovUrls
        self.dependencies.resolve(for: UserSessionRepository.self).saveToken("Token")
    }

    private func registerServicesLibraryDependencies() {
        self.dependencies.register(for: ClientsProvider.self) { _ in
            return self.servicesLibrary
        }
        self.dependencies.register(for: BizumRepository.self) { _ in
            return self.servicesLibrary.bizumRepository
        }
        self.dependencies.register(for: LoginRepository.self) { _ in
            return self.servicesLibrary.loginRepository
        }
        self.dependencies.register(for: ConfigurationRepository.self) { _ in
            return self.servicesLibrary.configurationRepository
        }
        self.dependencies.register(for: UserSessionRepository.self) { _ in
            return self.servicesLibrary.sessionRepository
        }
        self.dependencies.register(for: EnvironmentProvider.self) { _ in
            return self.servicesLibrary
        }
        self.dependencies.register(for: GetLanguagesSelectionUseCaseProtocol.self) { resolver in
            return GetLanguagesSelectionUseCase(dependencies: resolver)
        }

    }

    @IBAction private func goToHomeModule() {
        self.registerDependenciesForHomeModule()
        self.registerServicesLibraryDependencies()
        self.performPublicFile()

        let input: BizumTypeUseCaseInput = BizumTypeUseCaseInput(type: .home)
        let useCase: UseCase<BizumTypeUseCaseInput, BizumTypeUseCaseOkOutput, StringErrorOutput> = self.dependenciesResolver.resolve(for: BizumTypeUseCase.self).setRequestValues(requestValues: input)
        let usecaseHandler: UseCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: useCase, useCaseHandler: usecaseHandler, onSuccess: { [weak self] response in
            switch response {
            case .native(let checkPayment):
                let configuration = BizumCheckPaymentConfiguration(bizumCheckPaymentEntity: checkPayment)
                self?.presentHomeModule(configuration)
            case .web:
                print("Can´t Go To Home of Bizum: BizumTypeUseCase - Ok")
            }
        }, onError: { _ in
            print("Can´t Go To Home of Bizum: BizumTypeUseCase - Error")
        })
    }
    
    private func presentHomeModule(_ configuration: BizumCheckPaymentConfiguration) {
        self.dependencies.register(for: BizumCheckPaymentConfiguration.self, with: { _ in
            return configuration
        })
        self.navController = UINavigationController()
        self.present(self.navController, animated: true) {
            let coordinator = BizumModuleCoordinator(dependenciesResolver: self.dependenciesResolver, navigationController: self.navController)
            coordinator.start(.home)
        }
    }
    
    private func presentBiometryModule(_ configuration: BizumCheckPaymentConfiguration) {
        self.dependencies.register(for: BizumCheckPaymentConfiguration.self, with: { _ in
            return configuration
        })
        self.dependencies.register(for: BiometryValidatorModuleCoordinatorDelegate.self, with: { _ in
            return self
        })
        self.dependencies.register(for: EmptyPurchasesPresenterProtocol.self) { dependenciesResolver in
            return EmptyPurchasesPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: EmptyPurchasesViewController.self) { _ in
            let presenter: EmptyPurchasesPresenter = self.dependencies.resolve()
            return EmptyPurchasesViewController(presenter: presenter)
        }
        self.dependencies.register(for: EmptyDialogViewController.self) { _ in
            let view: EmptyPurchasesViewController = self.dependencies.resolve()
            return EmptyDialogViewController(emptyViewController: view)
        }
        self.dependencies.register(for: PullOfferCandidatesUseCase.self) { dependenciesResolver in
            return PullOfferCandidatesUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: CoreSessionManager.self) { _ in
            return CoreSessionManagerMock(configuration: self.dependencies.resolve(for: SessionConfiguration.self))
        }
        self.dependencies.register(for: SessionConfiguration.self) { _ in
            return SessionConfiguration(timeToExpireSession: 10000000000000,
                                        timeToRefreshToken: 10000000000000,
                                        sessionStartedActions: [],
                                        sessionFinishedActions: [])}
        self.navController = UINavigationController()
        navController.modalPresentationStyle = .fullScreen
        self.present(self.navController, animated: true) {
            let coordinator = BiometryValidatorModuleCoordinator(dependenciesResolver: self.dependenciesResolver, navigationController: self.navController)
            coordinator.start()
        }
    }
    
    @IBAction private func goToBizumSplitExpenses() {
        self.navController = UINavigationController()
        self.present(self.navController, animated: true, completion: {
            let operation = MockOperation(amount: AmountEntity(value: -100), concept: "Batman 80 years", productAlias: "Product")
            self.goToBizumSplitExpenses(operation)
        })
    }
    
    internal lazy var dependencies: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: BSANManagersProvider.self) { _ in
            return self.quickSetup.managersProvider
        }
        defaultResolver.register(for: BSANDataProvider.self) { _ in
            return self.quickSetup.bsanDataProvider
        }
        defaultResolver.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }
        defaultResolver.register(for: PullOffersInterpreter.self) { _ in
            return PullOffersInterpreterMock()
        }
        defaultResolver.register(for: GlobalPositionRepresentable.self) { _ in
            return self.globalPosition
        }
        defaultResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver,
                                                         globalPosition: globalPosition,
                                                         saveUserPreferences: true)
            return merger
        }
        defaultResolver.register(for: TrackerManager.self) { _ in
            return TrackerManagerMock()
        }
        defaultResolver.register(for: TimeManager.self) { _ in
            return self.localeManager
        }
        defaultResolver.register(for: StringLoader.self) { _ in
            return self.localeManager
        }
        defaultResolver.register(for: BizumModuleCoordinator.self) { defaultResolver in
            return BizumModuleCoordinator(dependenciesResolver: defaultResolver, navigationController: self.navController)
        }
        defaultResolver.register(for: AppConfigRepositoryProtocol.self) { _ in
            return AppConfigRepositoryFake()
        }
        defaultResolver.register(for: LocalAppConfig.self) { _ in
            return QuickSetup.LocalAppConfigMock()
        }
        defaultResolver.register(for: GlobalPositionReloadEngine.self, with: { _ in
            return self.reloadEngine
        })
        defaultResolver.register(for: FaqsRepositoryProtocol.self, with: { _ in
            return FaqsRepositoryFake()
        })
        
        defaultResolver.register(for: ColorsByNameEngine.self, with: { _ in
            return ColorsByNameEngine()
        })
        
        defaultResolver.register(for: BizumHomeModuleCoordinatorDelegate.self) { _ in
            return self
        }
        defaultResolver.register(for: UseCaseScheduler.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: UseCaseHandler.self)
        }
        defaultResolver.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        defaultResolver.register(for: SegmentedUserRepositoryProtocol.self) { _ in
            return SegmentedUserRepositoryMock()
        }
        defaultResolver.register(for: OperativeContainerCoordinatorDelegate.self) { _ in
            return self
        }
        defaultResolver.register(for: GlobalPositionReloader.self) { _ in
            return self
        }
        defaultResolver.register(for: ContactPermissionsManagerProtocol.self) { _ in
            return ContactPermissionsManager()
        }
        defaultResolver.register(for: BizumDefaultNGOsRepositoryProtocol.self) { _ in
            return BizumDefaultNGOsRepositoryMock()
        }
        defaultResolver.register(for: BaseURLProvider.self, with: { _ in
            return BaseURLProvider(baseURL: nil)
        })
        defaultResolver.register(for: LocalAuthenticationPermissionsManagerProtocol.self) { _ in
            return LocalAuthenticationPermissionsManagerMock()
        }
        defaultResolver.register(for: PushNotificationsRegisterManagerProtocol.self) { _ in
            return PushNotificationRegisterManagerMock()
        }
        defaultResolver.register(for: OtpPushManagerProtocol.self) { _ in
            return OtpPushManagerMock()
        }
        defaultResolver.register(for: APPNotificationManagerBridgeProtocol.self) { _ in
            return APPNotificationManagerBridgeMock()
        }
        defaultResolver.register(for: CompilationProtocol.self) { _ in
            return CompilationMock()
        }
        defaultResolver.register(for: GetLanguagesSelectionUseCaseProtocol.self) { resolver in
            return GetLanguagesSelectionUseCase(dependencies: resolver)
        }
        Localized.shared.setup(dependenciesResolver: defaultResolver)
        return defaultResolver
    }()
    
    private lazy var localeManager: LocaleManager = {
        let locale = LocaleManager(dependencies: dependencies)
        locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        return locale
    }()

    private lazy var touchIdData = TouchIdData(deviceMagicPhrase: "",
                                               touchIDLoginEnabled: true,
                                               footprint: "")

}

class PushNotificationRegisterManagerMock: PushNotificationsRegisterManagerProtocol {
    func registerNotificationHandler(_ handler: PushNotificationsHandler) {}
    func unregisterNotificationHandler() {}
}

class APPNotificationManagerBridgeMock: APPNotificationManagerBridgeProtocol {
    func getOtpPushManager() -> OtpPushManagerProtocol? {
        return OtpPushManagerMock()
    }
}

class OtpPushManagerMock: OtpPushManagerProtocol {
    func getDeviceToken() -> Data? {
        Data()
    }

    func handleOTP() {}

    func registerOtpHandler(handler: OtpNotificationHandler) {}

    func unregisterOtpHandler() {}

    func removeOtpFromUserPref() {}

    func didRegisterForRemoteNotifications(deviceToken: Data) {}

    func registerOtpPushAndSaveToken(deviceId: String) {}

    func updateToken(completion: @escaping ((Bool, CoreFoundationLib.ReturnCodeOTPPush?) -> Void)) {
        completion(true, .rightRegisteredDevice)
    }
}

class SegmentedUserRepositoryMock: SegmentedUserRepositoryProtocol {
    
    func getSegmentedUser() -> SegmentedUserDTO? {
        return nil
    }
    
    func getSegmentedUserSpb() -> [SegmentedUserTypeDTO]? {
        return nil
    }
    
    func getSegmentedUserGeneric() -> [SegmentedUserTypeDTO]? {
        return nil
    }
}

class PullOffersInterpreterMock: PullOffersInterpreter {
    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool {
        return false
    }
    
    func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]? {
        return nil
    }
    
    func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO? {
        return nil
    }
    
    func getValidOffer(offerId: String) -> OfferDTO? {
        return nil
    }
    
    func getOffer(offerId: String) -> OfferDTO? {
        return nil
    }
    
    func setCandidates(locations: [String: [String]], userId: String, reload: Bool) {
        
    }
    
    func expireOffer(userId: String, offerDTO: OfferDTO) {
        
    }
    
    func removeOffer(location: String) {
        
    }
    
    func disableOffer(identifier: String?) {
    }
    
    func reset() {
        
    }
    
    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool {
        return false
    }
}

class TrackerManagerMock: TrackerManager {
    
    func trackScreen(screenId: String, extraParameters: [String: String]) {
        print("TrackScreen screenId: \(screenId), extraParameters: \(extraParameters)", separator: ",", terminator: "\n")
    }
    
    func trackEvent(screenId: String, eventId: String, extraParameters: [String: String]) {
        print("TrackEvent (eventId: \(eventId), screenId: \(screenId), extraParameters: \(extraParameters)", separator: ",", terminator: "\n")
    }
    
    func trackEmma(token: String) {
        print("METRICS token Emma: \(token)")
    }
}

class ContactPermissionsManagerMock: ContactPermissionsManagerProtocol {
    
    func isContactsAccessEnabled() -> Bool {
        true
    }
    
    func isAlreadySet(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func askAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func getContacts(includingImages: Bool, completion: @escaping ([UserContactEntity]?, ContactsPersmissionStatus) -> Void) {
        let phone = UserContactPhoneEntity(alias: "Movil", number: "8885555512")
        let contact = UserContactEntity(identifier: "HJ45iio", name: "John", surname: "Appleseed", thumbnail: nil, phones: [phone])
        completion([contact], ContactsPersmissionStatus.success)
    }
}

extension ViewController: GlobalPositionReloader {
    func reloadGlobalPosition() {
        self.reloadEngine.globalPositionDidReload()
    }
}

extension ViewController: OperativeLauncherHandler {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
    
    var operativeNavigationController: UINavigationController? {
        return self.navController
    }
    
    func showOperativeLoading(completion: @escaping () -> Void) {
        self.showLoading(title: localized("generic_popup_loadingContent"), subTitle: localized("loading_label_moment"), completion: completion)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        self.dismissLoading(completion: completion)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        print("ERROR!!")
        print(keyDesc ?? "")
        completion?()
    }
}

extension ViewController: LoadingViewPresentationCapable {
    var associatedLoadingView: UIViewController {
        return self.presentingViewController ?? self.presentedViewController ?? self
    }
}

extension ViewController: OperativeContainerCoordinatorDelegate {
    func handleGiveUpOpinator(_ opinator: OpinatorInfoProtocol, completion: @escaping () -> Void) {
        completion()
    }
    
    func handleWebView(with data: Data, title: String) {
    }
    
    func executeOffer(_ offer: OfferEntity) {
        
    }
    func executeOffer(_ offer: OfferRepresentable) {
        
    }
    
    func handleOpinator(_ opinator: OpinatorInfoProtocol) {
        
    }
}

extension ViewController: BizumHomeModuleCoordinatorDelegate, BizumRefundMoneyOperativeLauncher,
                          BizumAcceptMoneyRequestOperativeLauncher, BizumSendMoneyLauncher, BizumRequestMoneyLauncher,
                          BizumSplitExpensesOperativeLauncher, BizumDonationOperativeLauncher {
    func goToAmountSendMoney(_ contact: BizumContactEntity) {
        
    }
    
    func goToBizumSplitExpenses(_ operation: SplitableExpenseProtocol) {
        goToBizumSplitExpenses(operation, handler: self)
    }
    
    func goToBizumCancelRequest(_ operation: BizumHistoricOperationEntity) {
        
    }
    
    func goToBizumRejectSend(_ operation: BizumHistoricOperationEntity) {
        
    }
    
    func goToBizumRejectRequest(_ operation: BizumHistoricOperationEntity) {
        
    }
    
    func goToBizumSendMoney(_ contacts: [BizumContactEntity]?) {
        goToBizumSendMoney(contacts, sendMoney: nil, handler: self)
    }
    
    func goToBizumRequestMoney(_ contacts: [BizumContactEntity]?) {
        goToBizumRequestMoney(contacts, sendMoney: nil, handler: self)
    }
    
    func goToReuseSendMoney(_ contact: BizumContactEntity, bizumSendMoney: BizumSendMoney) {
        
    }
    
    func goToReuseRequestMoney(_ contact: BizumContactEntity, bizumSendMoney: BizumSendMoney) {
        
    }
    
    func didSelectMenu() {
        
    }
    
    func goToBizumAcceptRequestMoney(_ operation: BizumHistoricOperationEntity) {
        goToBizumAcceptMoneyRequest(operation, handler: self)
    }
    
    func goToBizumRefundMoney(operation: BizumHistoricOperationEntity) {
        showBizumRefundMoney(operation: operation, handler: self)
    }
    
    func goToBizumCancel(_ operationEntity: BizumHistoricOperationEntity) {
        
    }
    
    func goToVirtualAssistant() {
    }
    
    func goToBizumWeb(configuration: WebViewConfiguration) {
        print("Go to Bizum web")
    }
    
    func goToBizumDonations() {
        goToBizumDonation(handler: self)
    }
    
    func didSelectOffer(offer: OfferEntity) {
        
    }
    
    func didSelectSearch() {
    }
}

class ContactPermissionsManager: ContactPermissionsManagerProtocol {
    func getContacts(includingImages: Bool, completion: @escaping ([UserContactEntity]?, ContactsPersmissionStatus) -> Void) {
        completion(
            [
                UserContactEntity(identifier: "0001", name: "Paquito", surname: "String", thumbnail: nil, phones: [UserContactPhoneEntity(alias: "", number: "722568844")]),
                UserContactEntity(identifier: "0002", name: "Norberto", surname: "String", thumbnail: nil, phones: [UserContactPhoneEntity(alias: "", number: "655107540")]),
                UserContactEntity(identifier: "0003", name: "Adac", surname: "String", thumbnail: nil, phones: [UserContactPhoneEntity(alias: "", number: "666666668")]),
                UserContactEntity(identifier: "0004", name: "Taema", surname: "String", thumbnail: nil, phones: [UserContactPhoneEntity(alias: "", number: "666666669")]),
                UserContactEntity(identifier: "0005", name: "OPAsda", surname: "String", thumbnail: nil, phones: [UserContactPhoneEntity(alias: "", number: "666666610")])
            ], .success
        )
    }
    
    func isContactsAccessEnabled() -> Bool {
        return true
    }
    
    func isAlreadySet(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func askAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}

class RepositoryResponseFake<P>: RepositoryResponse<P> {
    override func isSuccess() -> Bool {
        return true
    }
    
    override func getResponseData() throws -> P? {
        return nil
    }
    
    override func getErrorCode() throws -> CLong {
        return 0
    }
    
    override func getErrorMessage() throws -> String {
        
        func getAppConfigListNode<T>(_ nodeName: String, object: T.Type, options: AppConfigDecodeOptions) -> [T]? where T: Decodable {
            return nil
        }
        return ""
    }
}

class FaqsRepositoryFake: FaqsRepositoryProtocol {
    func getFaqsList(_ type: FaqsType) -> [FaqDTO] {
        return []
    }
    
    func getFaqsList() -> FaqsListDTO? {
        return nil
    }
}

class BizumDefaultNGOsRepositoryMock: BizumDefaultNGOsRepositoryProtocol {
    func getDefaultNGOs() -> BizumDefaultNGOsListDTO? {
        return nil
    }
    
    func load(baseUrl: String, language: PublicLanguage) { }
}

extension ViewController: BiometryValidatorModuleCoordinatorDelegate {
    func getScreen() -> String { "" }

    func biometryDidDisappear(withError error: String?) { }

    func biometryDidSuccessfullyDisappear() { }

    func continueSignProcess() { }

    func success(deviceToken: String, footprint: String, onCompletion: @escaping (Bool, String?) -> Void) {
        onCompletion(true, nil)
    }

    func cancel() { }
    
    func moreInfo() {
        let dialog = self.dependenciesResolver.resolve(for: EmptyDialogViewController.self)
        self.navController.present(dialog, animated: true, completion: nil)
    }
}

struct CoreSessionManagerMock: CoreSessionManager {
    var configuration: SessionConfiguration
    var isSessionActive: Bool { true }
    var lastFinishedSessionReason: SessionFinishedReason?
    func setLastFinishedSessionReason(_ reason: SessionFinishedReason) {}
    func sessionStarted(completion: (() -> Void)?) {}
    func finishWithReason(_ reason: SessionFinishedReason) {}
}
