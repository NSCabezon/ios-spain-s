import UIKit
import CorePushNotificationsService
import CoreFoundationLib
import QuickSetup
import Operative
import Localization
import SANLegacyLibrary
import CoreTestData
import CoreDomain
import OpenCombine

class ViewController: UIViewController {
    
    weak var operativeNavigationController: UINavigationController?
    private var mockDataInjector = MockDataInjector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.operativeNavigationController = self.navigationController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentModule()
    }
    
    private func presentModule() {
        self.showFakeOperative(delegate: self)
    }
    
    internal lazy var dependenciesResolver: DependenciesResolver = {
        
        let defaultResolver = DependenciesDefault()
        
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        defaultResolver.register(for: BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        
        defaultResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            return GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
        }
        
        defaultResolver.register(for: LocalAppConfig.self) { _ in
            let appConfig = LocalAppConfigMock()
            appConfig.language = .spanish
            appConfig.languageList = [.spanish]
            return appConfig
        }
        
        defaultResolver.register(for: AppConfigRepositoryProtocol.self) { _ in
            return AppConfigRepositoryFake()
        }
        
        defaultResolver.register(for: GlobalPositionReloader.self) { resolver in
            return GlobalPositionReloaderFake(dependencies: resolver)
        }

        defaultResolver.register(for: OtpPushManagerProtocol.self) { _ in
            return PushNotificationRegisterManagerProtocolMock()
        }
        
        Localized.shared.setup(dependenciesResolver: defaultResolver)
        return defaultResolver
    }()
    
    private lazy var localeManager: LocaleManager = {
        let locale = LocaleManager(dependencies: dependenciesResolver)
        locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        return locale
    }()
    
}

extension ViewController: FakeOperativeLauncher {
}

class PushNotificationRegisterManagerProtocolMock: OtpPushManagerProtocol {
    var otp: (String?, Date?)?
    var handler: OtpNotificationHandler?
    
    func handleOTP() {
        handler?.handleOTPCode(otp?.0, date: otp?.1)
    }
    
    func registerOtpHandler(handler: OtpNotificationHandler) {
        self.handler = handler
    }
    
    func unregisterOtpHandler() {
        self.handler = nil
    }
    
    func removeOtpFromUserPref() { }
    
    func didRegisterForRemoteNotifications(deviceToken: Data) { }
    
    func registerOtpPushAndSaveToken(deviceId: String) {}
    
    func updateToken(completion: @escaping ((Bool, CoreFoundationLib.ReturnCodeOTPPush?) -> Void)) {
        completion(true, .rightRegisteredDevice)
    }
    
    func getDeviceToken() -> Data? {
        return Data()
    }
}

extension ViewController: OperativeContainerLauncher {}

extension ViewController: OperativeLauncherHandler {
    
    func showOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
    }
}

class PfmController: PfmControllerProtocol {
    func cancelAll() { }
    
    var isFinish: Bool = false
    var monthsHistory: [MonthlyBalanceRepresentable]? = nil
    
    func removePFMSubscriber(_ subscriber: PfmControllerSubscriber) {
        
    }
    
    func isPFMAccountReady(account: AccountEntity) -> Bool {
        return true
    }
    
    func isPFMCardReady(card: CardEntity) -> Bool {
        return true
    }
    
    func registerPFMSubscriber(with subscriber: PfmControllerSubscriber) {
        
    }
}

class GlobalPositionReloaderFake: GlobalPositionReloader {
    let dependencies: DependenciesResolver
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func reloadGlobalPosition() {
        self.dependencies.resolve(for: GlobalPositionReloadEngine.self).globalPositionDidReload()
    }
}

class PullOffersInterpreterMock: PullOffersInterpreter {
    func disableOffer(identifier id: String?) {}
    
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
    
    func reset() {
        
    }
    
    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool {
        return false
    }
}

class AppConfigRepositoryFake: AppConfigRepositoryProtocol {
    func value<Value>(for key: String) -> AnyPublisher<Value?, Never> where Value : LosslessStringConvertible {
        fatalError()
    }
    
    func value<Value>(for key: String, defaultValue: Value) -> AnyPublisher<Value, Never> where Value : LosslessStringConvertible {
        fatalError()
    }
    
    func values<Value>(for keys: [String : Value]) -> AnyPublisher<[String : Value], Never> where Value : LosslessStringConvertible {
        fatalError()
    }
    
    func values<Value>(for keys: [String]) -> AnyPublisher<[Value?], Never> where Value : LosslessStringConvertible {
        fatalError()
    }
    
    
    func getAppConfigListNode<T>(_ nodeName: String, object: T.Type, options: AppConfigDecodeOptions) -> [T]? where T : Decodable {
        return nil
    }
    
    func getInt(_ nodeName: String) -> Int? {
        return nil
    }
    
    func getAppConfigListNode(_ nodeName: String) -> [String]? {
        return nil
    }
    
    func getBool(_ nodeName: String) -> Bool? {
        return nil
    }
    func getDecimal(_ nodeName: String) -> Decimal? {
        return nil
    }
    func getString(_ nodeName: String) -> String? {
        return nil
    }
}
