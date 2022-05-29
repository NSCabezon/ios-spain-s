
import UIKit
import QuickSetup
import SantanderKeyAuthorization
import UI
import CoreDomain
import CoreTestData
import CoreFoundationLib
import OpenCombine
import SantanderKeyAuthorization

class ViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var goToSKFirstButton: UIButton!
    let rootNavigationController = UINavigationController()
    
    var childCoordinators: [Coordinator] = []
    
    override func viewDidAppear(_ animated: Bool) {
        UIStyle.setup()
        activityIndicator.isHidden = true
        goToSKFirstButton.isHidden = false
        super.viewDidAppear(animated)
        Toast.enable()
    }
    
    @IBAction func gotoSKModule(_ sender: Any) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        goToSKFirstButton.isHidden = true
        rootNavigationController.modalPresentationStyle = .fullScreen
        self.present(rootNavigationController, animated: false, completion: {
            self.goToSKAuthorizationFirst()
        })
    }
    
    private lazy var dependenciesResolver: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: UINavigationController.self) { _ in
            return self.rootNavigationController
        }
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        return defaultResolver
    }()
}

extension ViewController {
    
    func goToSKAuthorizationFirst() {
        let dependencies = ModuleDependencies(dependenciesResolver: dependenciesResolver)
        dependencies.skAuthorizationCoordinator().start()
    }
}

//MARK:  SKAuthorization dependencies

class ModuleDependencies: SantanderKeyAuthorizationExternalDependenciesResolver {
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
}
