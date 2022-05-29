import CoreFoundationLib
import UI
import SANLegacyLibrary
import CoreDomain

public protocol GlobalSearchMainModuleCoordinatorDelegate: class {
    func didSelectDismiss()
    func didSelectAccountMovement(_ movement: AccountTransactionEntity,
                                  in transactions: [AccountTransactionWithAccountEntity],
                                  for account: AccountEntity)
    func didSelectCardMovement(_ movement: CardTransactionEntity,
                               in transactions: [CardTransactionWithCardEntity],
                               for card: CardEntity)
    func goToBills()
    func goToTransfers()
    func goToSwitchOffCard()
    func open(url: String)
    func showAlertDialog(acceptTitle: LocalizedStylableText,
                         cancelTitle: LocalizedStylableText?,
                         title: LocalizedStylableText?,
                         body: LocalizedStylableText,
                         acceptAction: (() -> Void)?,
                         cancelAction: (() -> Void)?)
    func executeOffer(_ offer: OfferRepresentable)
    func executeDeepLink(_ deepLinkIdentifier: String)
}

public class GlobalSearchMainModuleCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: GlobalSearchViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
    
        self.dependenciesEngine.register(for: GlobalSearchPresenterProtocol.self) { dependenciesResolver in
            return GlobalSearchPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GlobalSearchViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: GlobalSearchViewController.self)
        }
        
        self.dependenciesEngine.register(for: GlobalSearchViewController.self) { dependenciesResolver in
            var presenter: GlobalSearchPresenterProtocol = dependenciesResolver.resolve(for: GlobalSearchPresenterProtocol.self)
            let viewController = GlobalSearchViewController(nibName: "GlobalSearchViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: GlobalSearchUseCase.self) { _ in
            return GlobalSearchUseCase()
        }
        
        self.dependenciesEngine.register(for: GlobalSearchCheckProductsUseCase.self) { _ in
            return GlobalSearchCheckProductsUseCase()
        }
        
        self.dependenciesEngine.register(for: GetReportMovementsPhoneNumberUseCase.self) { _ in
            return GetReportMovementsPhoneNumberUseCase()
        }
        
        self.dependenciesEngine.register(for: GetGlobalSearchFAQsUseCase.self) { dependenciesResolver in
            return GetGlobalSearchFAQsUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetSearchKeywordsUseCase.self) { dependenciesResolver in
            return GetSearchKeywordsUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}
