import UIKit
import QuickSetup
import Menu
import CoreFoundationLib
import Localization
import CoreTestData
import UI
import CoreDomain

final class ViewController: UIViewController {
    
    private let rootNavigationController = UINavigationController()
    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    
    private var mockDataInjector = MockDataInjector()
    private var serviceInjectors: [CustomServiceInjector] {
        return [MenuServiceInjector()]
    }

    private lazy var navigation: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }()
    
    private lazy var coordinator: MenuModuleCoordinator = {
        return MenuModuleCoordinator(dependenciesResolver: dependenciesResolver,
                                     navigationController: navigation)
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentModule()
    }
    
    private func presentModule() {
        rootNavigationController.modalPresentationStyle = .fullScreen
        present(rootNavigationController, animated: false, completion: {
            self.goToPublicMenu()
        })
    }
    
    private func goToPublicMenu() {
        moduleDependencies
            .publicMenuSceneCoordinator()
            .start()
    }
    
    func goToAnalysisArea() {
        moduleDependencies
            .analysisAreaHomeCoordinator()
            .start()
    }
    
    private lazy var moduleDependencies: ModuleDependencies = {
        ModuleDependencies(dependenciesResolver: dependenciesResolver)
    }()
    
    private lazy var dependenciesResolver: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: UINavigationController.self) { _ in
            return self.rootNavigationController
        }
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return self.serviceInjectors
        }
        defaultResolver.register (for: UINavigationController.self) { _ in
            return self.rootNavigationController
        }
        self.servicesProvider.registerDependencies(in: defaultResolver)
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        MenuDependenciesInitializer(dependencies: defaultResolver).registerDependencies()
        defaultResolver.register(for: FractionedPaymentsLauncher.self) { _ in
            FractionedPaymentsLauncherMock()
        }
        return defaultResolver
    }()
}

final class ModuleDependencies: PublicMenuExternalDependenciesResolver, PublicMenuRepositoriesResolver, GlobalResolver, AnalysisAreaExternalDependenciesResolver {
    func otpCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> GetCandidateOfferUseCase {
        fatalError()
    }
    
    func offersCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func resolve() -> UserSessionFinancialHealthRepository {
        MockUserSessionFinancialHealthRepository(mockDataInjector: MockDataInjector())
    }
    
    func resolve() -> FinancialHealthRepository {
        let dependenciesResolver: DependenciesResolver = resolve()
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> TrackerManager {
        fatalError()
    }
    
    func resolve() -> ReactivePullOffersInterpreter {
        MockReactivePullOffersInterpreter(mockDataInjector: MockDataInjector())
    }
    
    func resolve() -> BaseURLProvider {
        BaseURLProvider(baseURL: "")
    }
    
    func resolve() -> ReactivePullOffersConfigRepository {
        MockReactivePullOffersConfigRepository()
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func resolve() -> PublicMenuActionsRepository {
        DefaultPublicMenuActionRepository()
    }
    
    func resolveSideMenuNavigationController() -> UINavigationController {
        self.resolve()
    }
    
    func publicMenuATMLocatorCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func asShared<Dependency>(_ dependency: () -> Dependency) -> Dependency {
        fatalError()
    }
    
    var dependenciesResolver: DependenciesInjector & DependenciesResolver
    
    init(dependenciesResolver: DependenciesInjector & DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func resolve() -> UINavigationController {
        return dependenciesResolver.resolve(for: UINavigationController.self)
    }
    
    func resolve() -> DependenciesResolver {
        return dependenciesResolver
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolvePrivateMenuCoordinator() -> Coordinator {
        return dependenciesResolver.resolve()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        return ToastCoordinator("Select Menu")
    }
}

extension PublicMenuExternalDependenciesResolver {
    func resolve() -> PublicMenuToggleOutsider {
        return PublicMenuOutsiderMock()
    }
}

public protocol PublicMenuRepositoriesResolver {
    func resolve() -> PublicMenuRepository
    func resolve() -> HomeTipsRepository
    func resolve() -> SegmentedUserRepository
}

extension PublicMenuRepositoriesResolver {
    func resolve() -> HomeTipsRepository {
        return MockHomeTipsRepository()
    }
    
    func resolve() -> PublicMenuRepository {
        return PublicMenuRepositoryMock()
    }
    
    func resolve() -> SegmentedUserRepository {
        return MockSegmentedUserRepository(mockDataInjector: MockDataInjector())
    }
}

// MARK: - Mocked launcher action

final class FractionedPaymentsLauncherMock: FractionedPaymentsLauncher {
    func didSelectInMenu() {
    }
    
    func gotoCardEasyPayOperative(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?) {
    }
    
    func goToFractionedPaymentDetail(_ transaction: CardTransactionEntity, card: CardEntity) {
    }
}


final class PfmHelperMock: PfmHelperProtocol {
    func getMovementsFor(userId: String, date: Date, account: AccountEntity) -> [AccountTransactionEntity] {
        []
    }
    
    func getMovementsFor(userId: String, matches: String, account: AccountEntity, limit: Int, date: Date) -> [AccountTransactionEntity] {
        []
    }
    
    func getMovementsFor(userId: String, matches: String, card: CardEntity, limit: Int, date: Date) -> [CardTransactionEntity] {
        []
    }
    
    func getLastMovementsFor(userId: String, card: CardEntity) -> [CardTransactionEntity] {
        []
    }
    
    func getLastMovementsFor(userId: String, card: CardEntity, startDate: Date, endDate: Date) -> [CardTransactionEntity] {
        []
    }
    
    func getLastMovementsFor(userId: String, card: CardEntity, searchText: String, fromDate: Date, toDate: Date?) -> [CardTransactionEntity] {
        []
    }
    
    func getUnreadMovementsFor(userId: String, date: Date, account: AccountEntity) -> Int? {
        nil
    }
    
    func getUnreadMovementsFor(userId: String, date: Date, card: CardEntity) -> Int? {
        nil
    }
    
    func cardExpensesCalculationTransaction(userId: String, card: CardEntity) -> AmountEntity {
        AmountEntity(value: Decimal(0))
    }
    
    func setReadMovements(for userId: String, account: AccountEntity) {
        
    }
    
    func setReadMovements(for userId: String, card: CardEntity) {
        
    }
    
    func getMovementsFor(userId: String, date: Date, account: AccountEntity, searchText: String, toDate: Date?) -> [AccountTransactionEntity] {
        []
    }
    
    func getMovementsFor(userId: String, account: AccountEntity, startDate: Date, endDate: Date, includeInternalTransfers: Bool) -> [AccountTransactionEntity] {
        []
    }
    
    func getUnreadCardMovementsFor(userId: String, startDate: Date, card: CardEntity, limit: Int?) -> [CardTransactionEntity] {
        []
    }
    
    func getUnreadAccountMovementsFor(userId: String, startDate: Date, account: AccountEntity, limit: Int?) -> [AccountTransactionEntity] {
        []
    }
    
    func execute() {
        
    }
    
    func finishSession(_ reason: SessionFinishedReason?) {
        
    }
}

public typealias GlobalResolver = TrackerManagerResolver

public protocol TrackerManagerResolver {
    func resolve() -> TrackerManager
}

public extension TrackerManagerResolver {
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
}
