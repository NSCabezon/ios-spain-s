import UIKit
import CoreFoundationLib
import UI
import CoreDomain
import UIOneComponents
import FeatureFlags
import QuickSetup

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let navigationController = UINavigationController()
        self.present(navigationController, animated: true) {
            let coordinator = DefaultFeatureFlagsCoordinator(dependencies: FeatureFlagsDependenciesInitializer(dependencies: DependenciesDefault(), navigationController: navigationController))
            coordinator.start()
        }
    }
}
