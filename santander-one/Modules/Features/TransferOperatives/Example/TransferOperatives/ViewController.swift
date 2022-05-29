import CoreFoundationLib
import CoreDomain
import TransferOperatives
import CoreTestData
import QuickSetup
import Transfer
import UIKit
import UI
import CoreTestData

final class ViewController: UIViewController {
    @IBOutlet private weak var stackView: UIStackView!

    var rootNavigationController: UINavigationController {
        self.navigationController ?? UINavigationController()
    }
    
    let quickSetup = QuickSetupForCoreTestData()
    
    private lazy var servicesProvider: ServicesProvider = {
        return quickSetup
    }()

    private var serviceInjectors: [CustomServiceInjector] {
        return [
            TransferOperativesServiceInjector()
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootNavigationController.modalPresentationStyle = .fullScreen
        addOperatives()
    }
    
    private lazy var dependencies: DependenciesInjector & DependenciesResolver = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: UINavigationController.self) { _ in
            return self.rootNavigationController
        }
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return self.serviceInjectors
        }
        servicesProvider.registerDependencies(in: defaultResolver)
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        quickSetup.registerDependencies(in: defaultResolver)
        TransferOperativesDependenciesInitializer(dependencies: defaultResolver, injector: quickSetup.mockDataInjector).registerDependencies()
        TransferDependenciesInitializer(dependencies: defaultResolver, injector: quickSetup.mockDataInjector, navController: rootNavigationController).registerDependencies()
        return defaultResolver
    }()
}
    
private extension ViewController {
    func addOperatives() {
        let operatives = [#selector(launchSendMoney)]
        operatives.forEach { selector in
            let button = UIButton()
            button.setTitle(selector.description, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: selector, for: .touchUpInside)
            button.backgroundColor = .white
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc func launchSendMoney() {
      //  let coordinator = TransferHomeModuleCoordinator(dependenciesResolver: dependencies, navigationController: rootNavigationController)
      //  coordinator.didSelectTestNewSendMoney()
    }
}

extension ViewController: LoadingViewPresentationCapable {}

struct ModuleDependencies {
    let oldResolver: DependenciesInjector & DependenciesResolver
    let navigationController: UINavigationController
    let coreDependencies = DefaultCoreDependencies()
    
    func resolve() -> TimeManager {
        oldResolver.resolve()
    }
    
    func resolve() -> DependenciesResolver {
        return oldResolver
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        oldResolver.resolve()
    }
    
    func resolve() -> UINavigationController {
        return navigationController
    }
    
    func globalSearchCoordinator() -> Coordinator {
        return ToastCoordinator("Select Global Search")
    }
    
    func privateMenuCoordinator() -> Coordinator {
        return ToastCoordinator("Select Menu")
    }
}

extension ModuleDependencies: CoreDependenciesResolver {
    func resolve() -> CoreDependencies {
        return coreDependencies
    }
}

extension ModuleDependencies: TransferOperativesExternalDependenciesResolver {
    func resolve() -> CurrencyFormatterProvider {
        fatalError()
    }
    
    func resolve() -> InternalTransferAmountModifierProtocol? {
        fatalError()
    }
    
    func resolve() -> TrackerManager {
        TrackerManagerMock()
    }
    
    func resolve() -> GlobalPositionDataRepository {
        fatalError()
    }
    
    func resolve() -> AccountNumberFormatterProtocol? {
        fatalError()
    }
}
