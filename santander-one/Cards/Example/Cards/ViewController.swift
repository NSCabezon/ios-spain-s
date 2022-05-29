import UIKit
import Cards
import CoreFoundationLib
import CoreDomain
import CoreTestData
import UI
import QuickSetup
import SANLegacyLibrary

final class ViewController: UIViewController {
    
    private lazy var nav: UINavigationController = {
        let navController = UINavigationController()
        navController.modalPresentationStyle = .fullScreen
        return navController
    }()
    
    private let dependenciesEngine = DependenciesDefault()
    
    private lazy var moduleDepencencies: ModuleDependencies = {
        return ModuleDependencies(dependenciesResolver: dependenciesResolver)
    }()
    
    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    private var serviceInjectors: [CustomServiceInjector] {
        return [CardsServiceInjector()]
    }
    
    private let cardServiceInjector = CardsServiceInjector()
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerDependencies()
        let cards = dependenciesResolver
            .resolve(for: GlobalPositionRepresentable.self)
            .cards
        let userId = dependenciesResolver
            .resolve(for: GlobalPositionRepresentable.self)
            .userId
        
        self.present(nav, animated: false, completion: {
            self.presentCardsHome(with: cards[1].representable, userId: userId)
        })
        Toast.enable()
    }
    
    private lazy var dependenciesResolver: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: UINavigationController.self) { _ in
            return self.nav
        }
        defaultResolver.register(for: PfmHelperProtocol.self) { _ in
            return PullOffersInterpreterMock()
        }
        defaultResolver.register(for: ApplePayEnrollmentManager.self) { resolver in
            return ApplePayEnrollmentManager(dependenciesResolver: resolver)
        }
        defaultResolver.register(for: GlobalPositionReloader.self) { _ in
            return self
        }
        defaultResolver.register(for: CardTransactionsSearchModifierProtocol.self) { _ in
            return CardTransactionsSearchModifier()
        }
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        CardsDependenciesInitializer(dependencies: defaultResolver).registerDependencies()
        return defaultResolver
    }()
}

struct CardTransactionsSearchModifier: CardTransactionsSearchModifierProtocol {
    var isSearchLimitedBySCA: Bool {
        return false
    }
    
    var isTransactionNameFilterEnabled: Bool {
        return true
    }
    
    var isIncomeExpensesFilterEnabled: Bool {
        return true
    }
    
    var isAmountsRangeFilterEnabled: Bool {
        return true
    }
    
    var isOperationTypeFilterEnabled: Bool {
        return true
    }
}

private extension ViewController {
    func registerDependencies() {
        dependenciesResolver.register(for: [CustomServiceInjector].self) { resolver in
            return self.serviceInjectors
        }
        self.servicesProvider.registerDependencies(in: dependenciesResolver)
    }
    
    func presentCardsHome(with card: CardRepresentable?, userId: String?) {
        // Activate the feature flag for `cardTransactionFilters`
        let repository: FeatureFlagsRepository = moduleDepencencies.resolve()
        repository.save(value: .boolean(true), for: CoreFeatureFlag.cardTransactionFilters)
        // Go to the cards home
        let cardsHome = CardsHomeModuleCoordinator(
            dependenciesResolver: moduleDepencencies.resolve(),
            navigationController: moduleDepencencies.resolve(),
            externalDependencies: moduleDepencencies
        )
        cardsHome.start()
    }
}
//MARK: globals dependenceies
import Localization
import CoreFoundationLib

public protocol TimeManagerResolver {
    var timeManager: TimeManager { get }
    func resolve() -> TimeManager
}

public extension TimeManagerResolver {
    func resolve() -> TimeManager {
        return timeManager
    }
}

public protocol TrackerManagerResolver {
    func resolve() -> TrackerManager
}

public extension TrackerManagerResolver {
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
}

public protocol AppConfigRepositoryResolver {
    func resolve() -> AppConfigRepositoryProtocol
}

public extension AppConfigRepositoryResolver {
    func resolve() -> AppConfigRepositoryProtocol {
        MockAppConfigRepository(mockDataInjector: MockDataInjector())
    }
}

public protocol LegacyResolver {
    var dependenciesResolver: DependenciesResolver & DependenciesInjector { get }
    func resolve() -> DependenciesResolver
}

public extension LegacyResolver {
    func resolve() -> DependenciesResolver {
        return DependenciesDefault()
    }
}

public typealias GlobalResolver = TimeManagerResolver & TrackerManagerResolver & AppConfigRepositoryResolver & GlobalPositionDependenciesResolver & LegacyResolver

//MARK: Cards dependenceies

class ModuleDependencies:
    GlobalResolver,
    CardExternalDependenciesResolver,
    NavigationBarExternalDependenciesResolver,
    FeatureFlagsRepositoryDependenciesResolver,
    CardTransactionFiltersExternalDependenciesResolver {
    
    var dependenciesResolver: DependenciesInjector & DependenciesResolver
    var timeManager: TimeManager
    var coreDependencies = DefaultCoreDependencies()
    
    init(dependenciesResolver: DependenciesInjector & DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        let local = LocaleManager(dependencies: dependenciesResolver)
        local.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        timeManager = local
    }
    
    func resolve() -> CoreDependencies {
        return coreDependencies
    }
    
    func resolve() -> UINavigationController {
        return dependenciesResolver.resolve(for: UINavigationController.self)
    }
    
    func resolve() -> NavigationBarItemBuilder {
        return NavigationBarItemBuilder(dependencies: self)
    }
    
    func resolve() -> DependenciesResolver {
        return dependenciesResolver
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func globalSearchCoordinator() -> Coordinator {
        return ToastCoordinator("Select Global Search")
    }

    func privateMenuCoordinator() -> Coordinator {
        return ToastCoordinator("Select Menu")
    }
    
    func resolve() -> BaseURLProvider {
        return BaseURLProvider(baseURL: "https://microsite.bancosantander.es/filesFF/")
    }
    
    func resolve() -> [CardTextColorEntity] {
        return []
    }
  
    func resolve() -> CardDetailExternalDependenciesResolver {
        return self
    }
    
    func showPANCoordinator() -> BindableCoordinator {
        ToastCoordinator("Show PAN")
    }
    
    func cardActivateCoordinator() -> BindableCoordinator {
        ToastCoordinator("Active Card")
    }
    
    func resolve() -> BSANManagersProvider {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> AppRepositoryProtocol {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> BooleanFeatureFlag {
        return DefaultBooleanFeatureFlag(dependencies: self)
    }
    
    func resolve() -> FeatureFlagsRepository {
        return asShared {
            return DefaultFeatureFlagsRepository(features: CoreFeatureFlag.allCases)
        }
    }
    func resolve() -> StringLoader {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> LocalAppConfig {
        dependenciesResolver.resolve()
    }
    
    func offersCoordinator() -> BindableCoordinator {
        ToastCoordinator("Select Offers")
    }
    
    func resolve() -> PullOffersConfigRepositoryProtocol {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> PullOffersInterpreter {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> EngineInterface {
        dependenciesResolver.resolve()
    }
    
}

extension CardDetailExternalDependenciesResolver {
    func resolve() -> CardRepository {
        let dependencenciesResolver: DependenciesResolver = resolve()
        return dependencenciesResolver.resolve()
    }
    
    func resolve() -> GetCardDetailConfigurationUseCase {
        return DefaultGetCardDetailConfigurationUseCase()
    }
    
    func resolve() -> GlobalPositionReloader {
        let dependencenciesResolver: DependenciesResolver = resolve()
        return dependencenciesResolver.resolve()
    }
}

extension ViewController: GlobalPositionReloader {
    func reloadGlobalPosition() { }
}

