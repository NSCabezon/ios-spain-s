import UI
import CoreFoundationLib
import CoreDomain

public protocol HelperCenterCoordinatorProtocol {
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didSelectOffer(_ offer: OfferRepresentable?)
    func goToWebview()
    func didSelectEmergency(action: HelpCenterEmergencyAction)
    func goToWhatsapp(_ urlWhatsapp: URL)
    func goToPhoneCall(_ phoneNumber: String)
    func goToGlobalSearch()
    func goToHomeTips()
}

public class HelperCenterCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: HelperCenterViewController.self)
        if let globalPositionVC = navigationController?.viewControllers.first {
            navigationController?.setViewControllers([globalPositionVC, controller], animated: true)
        }
    }
    
    private func setupDependencies() {
        setupDenpendenciesUseCase()
        self.dependenciesEngine.register(for: HelperCenterPresenterProtocol.self) { dependenciesResolver in
            return HelperCenterPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: HelperCenterViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: HelperCenterViewController.self)
        }
        self.dependenciesEngine.register(for: HelperCenterViewController.self) { dependenciesResolver in
            let presenter: HelperCenterPresenterProtocol = dependenciesResolver.resolve(for: HelperCenterPresenterProtocol.self)
            let viewController = HelperCenterViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    private func setupDenpendenciesUseCase() {
        self.dependenciesEngine.register(for: GetHelpCenterUseCase.self) { dependenciesResolver in
            return GetHelpCenterUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetHelpCenterTipsUseCase.self) { dependenciesResolver in
            return GetHelpCenterTipsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetHasOneProductsUseCase.self) { dependenciesResolver in
            return GetHasOneProductsUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}
