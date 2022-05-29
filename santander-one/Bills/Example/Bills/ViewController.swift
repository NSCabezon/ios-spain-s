import QuickSetup
import Bills
import CoreFoundationLib
import Operative
import CoreTestData

final class ViewController: UIViewController {
    let provNavigation = UINavigationController()
    
    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    private var serviceInjectors: [CustomServiceInjector] {
        return [
            BillsServiceInjector()
        ]
    }
    
    lazy var dependenciesResolver: DependenciesResolver = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return self.serviceInjectors
        }
        defaultResolver.register(for: PaymentCoordinatorDelegate.self) { dependencies in
            return PaymentCoordinatorDelegateMock(dependenciesResolver: dependencies, navigator: self.provNavigation)
        }
        self.servicesProvider.registerDependencies(in: defaultResolver)
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        BillsDependenciesInitializer(dependencies: defaultResolver).registerDependencies()
        return defaultResolver
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentModule()
    }
    
    private func presentModule() {
        provNavigation.modalPresentationStyle = .fullScreen
        self.present(provNavigation, animated: false) {
            let coordinator = BillsModuleCoordinator(dependenciesResolver: self.dependenciesResolver, navigationController: self.provNavigation)
            coordinator.start(.payment)
        }
    }
}

extension ViewController: OperativeLauncherHandler {
    
    var operativeNavigationController: UINavigationController? {
        return self.presentedViewController as? UINavigationController
    }
    
    func showOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        completion?()
    }
}

extension ViewController: BillEmittersPaymentLauncher {}

extension ViewController: BillSearchFiltersCoordinatorDelegate {
    func didSelectDismiss() {
        provNavigation.popViewController(animated: true)
    }
    
    func showAlertDialog(acceptTitle: LocalizedStylableText,
                         cancelTitle: LocalizedStylableText?,
                         title: LocalizedStylableText?,
                         body: LocalizedStylableText,
                         acceptAction: (() -> Void)?,
                         cancelAction: (() -> Void)?) {
        
    }
}
