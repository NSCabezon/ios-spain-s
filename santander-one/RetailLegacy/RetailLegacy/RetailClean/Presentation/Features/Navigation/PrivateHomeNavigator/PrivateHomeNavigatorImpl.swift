import CoreFoundationLib
import FinantialTimeline
import PersonalManager
import GlobalPosition
import BranchLocator
import GlobalSearch
import PersonalArea
import CoreDomain
import WebViews
import Transfer
import Account
import Bills
import Cards
import UIKit
import Menu
import OpenCombine

final class PrivateHomeNavigatorImpl: AppStoreNavigator {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    let personalAreaCoordinator: PersonalAreaModuleCoordinator
    let personalManagerCoordinator: PersonalManagerModuleCoordinator
    let menuCoordinator: MenuModuleCoordinator
    let globalSearchCoordinator: GlobalSearchModuleCoordinator
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    weak var customNavigation: NavigationController?
    let billsModuleCoordinator: BillsModuleCoordinator
    let contactsDetailCoordinator: ContactDetailCoordinator
    let compilation: CompilationProtocol
    let productsNavigator: ProductsNavigatorProtocol
    var legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver
    let cardExternalDependencies: CardExternalDependenciesResolver
    internal var subscriptions: Set<AnyCancellable> = []
    
    lazy var errorHandler: GenericPresenterErrorHandler = {
        guard let viewController = drawer.currentRootViewController else {
            fatalError("There are no view controller as root")
        }
        return GenericPresenterErrorHandler(stringLoader: presenterProvider.dependencies.stringLoader, view: viewController, delegate: self, dependenciesResolver: self.dependenciesEngine)
    }()
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector, legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver, cardExternalDependencies: CardExternalDependenciesResolver) {
        customNavigation = drawer.currentRootViewController as? NavigationController
        self.cardExternalDependencies = cardExternalDependencies
        self.compilation = dependenciesEngine.resolve(for: CompilationProtocol.self)
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.personalAreaCoordinator = PersonalAreaModuleCoordinator(
            dependenciesResolver: presenterProvider.dependenciesEngine,
            navigationController: customNavigation ?? UINavigationController(),
            userPreferencesDependencies: legacyExternalDependenciesResolver
        )
        self.personalManagerCoordinator = PersonalManagerModuleCoordinator(dependenciesResolver: presenterProvider.dependenciesEngine, navigationController: customNavigation ?? UINavigationController())
        self.menuCoordinator = MenuModuleCoordinator(dependenciesResolver: presenterProvider.dependenciesEngine, navigationController: customNavigation ?? UINavigationController())
        self.billsModuleCoordinator = BillsModuleCoordinator(dependenciesResolver: presenterProvider.dependenciesEngine, navigationController: customNavigation
                                                             ?? UINavigationController())
        self.globalSearchCoordinator = GlobalSearchModuleCoordinator(dependenciesResolver: presenterProvider.dependenciesEngine, navigationController: customNavigation
                                                                     ?? UINavigationController())
        self.contactsDetailCoordinator = ContactDetailCoordinator(dependenciesResolver: presenterProvider.dependenciesEngine, navigationController: customNavigation ?? UINavigationController())
        self.dependenciesEngine = dependenciesEngine
        self.productsNavigator = self.presenterProvider.navigatorProvider.productsNavigator
        self.legacyExternalDependenciesResolver = legacyExternalDependenciesResolver
        super.init()
        self.registerPersonalAreaDependencies()
        drawer.sideMenuNotifier.add(self)
    }
}
