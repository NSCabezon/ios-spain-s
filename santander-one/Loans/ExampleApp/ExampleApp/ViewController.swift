import UIKit
import QuickSetup
import Loans
import CoreFoundationLib
import UI
import CoreDomain
import CoreTestData
import SANLegacyLibrary

class ViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var goToLoanHomeButton: UIButton!
    let rootNavigationController = UINavigationController()
    var dependencies: ModuleDependencies!

    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    
    private var serviceInjectors: [CustomServiceInjector] {
        return [LoansServiceInjector()]
    }
    
    var childCoordinators: [Coordinator] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dependencies = ModuleDependencies(dependenciesResolver: dependenciesResolver)
        self.servicesProvider.registerDependencies(in: dependenciesResolver)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.isHidden = true
        goToLoanHomeButton.isHidden = false
        super.viewDidAppear(animated)
        Toast.enable()
    }
    
    @IBAction func gotoLoanHomeModule(_ sender: Any) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        goToLoanHomeButton.isHidden = true
        let loans = dependenciesResolver
            .resolve(for: GlobalPositionRepresentable.self)
            .loans
        
        rootNavigationController.modalPresentationStyle = .fullScreen
        self.present(rootNavigationController, animated: false, completion: {
            self.goToLoanHome(with: loans[2].representable)
        })
    }
    
    private lazy var dependenciesResolver: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: UINavigationController.self) { _ in
            return self.rootNavigationController
        }
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return self.serviceInjectors
        }
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        return defaultResolver
    }()
}

extension ViewController {
    
    func goToLoanHome(with loan: LoanRepresentable?) {
        dependencies.loanHomeCoordinator()
            .set(loan)
            .start()
    }
}

//MARK: globals dependenceies
import Localization

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

public protocol AccountNumberFormatterResolver {
    func resolve() -> AccountNumberFormatterProtocol
}

extension AccountNumberFormatterResolver {
    func resolve() -> AccountNumberFormatterProtocol {
        return AccountNumberFormatterMock()
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

public typealias GlobalResolver = TimeManagerResolver & TrackerManagerResolver & CoreDependenciesResolver & AccountNumberFormatterResolver


//MARK: Loans dependenceies

class ModuleDependencies:
    GlobalResolver,
    LoanExternalDependenciesResolver, GlobalPositionDependenciesResolver {
    var dependenciesResolver: DependenciesInjector & DependenciesResolver
    var timeManager: TimeManager
    var coreDependencies = DefaultCoreDependencies()
    
    init(dependenciesResolver: DependenciesInjector & DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        let local = LocaleManager(dependencies: dependenciesResolver)
        local.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        timeManager = local
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
    
    func globalSearchCoordinator() -> Coordinator {
        return ToastCoordinator("Select Global Search")
    }
    
    func privateMenuCoordinator() -> Coordinator {
        return ToastCoordinator("Select Menu")
    }
    
    func resolve() -> CoreDependencies {
        coreDependencies
    }
    
    func loanTransactionDetailActionsCoordinator() -> BindableCoordinator {
        return ToastCoordinator(localized("generic_alert_notAvailableOperation"))
    }
    
    func resolve() -> StringLoader {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> BSANManagersProvider {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> AppRepositoryProtocol {
        dependenciesResolver.resolve()
    }
}

extension LoanExternalDependenciesResolver {
    
    func resolve() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func loanChangeLinkedAccountCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    public func resolve() -> LoansModifierProtocol? {
        return LoanModifierMock()
    }
    
    func resolve() -> LoanReactiveRepository {
        let dependencenciesResolver: DependenciesResolver = resolve()
        return dependencenciesResolver.resolve()
    }
    
    func resolve() -> GetLoanTransactionDetailConfigurationUseCase {
        GetLoanTransactionDetailConfigurationUseCaseMock()
    }
    
    func resolve() -> GetLoanTransactionDetailActionUseCase {
        GetLoanTransactionDetailActionUseCaseMock()
    }
    
    func resolve() -> GetLoanPDFInfoUseCase {
        GetLoanPDFInfoUseCaseMock()
    }
    
    func loanRepaymentCoordinator() -> BindableCoordinator {
        return ToastCoordinator(localized("Select repayment"))
    }
}
