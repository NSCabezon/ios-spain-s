import CoreFoundationLib
import Foundation
import UI
import UIKit
import OpenCombine
import CoreTestData

public enum Limits: Int {
    case maximunNumberOfImages = 50
    case stepNumberOfImages = 4
}

class ViewController: UIViewController {
    
    var coordinator: DefaultSendMoneyOperativeCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let navigation = UINavigationController()
        self.present(navigation, animated: true, completion: {
            let vc = UIViewController()
            vc.view.backgroundColor = .red
            navigation.pushViewController(vc, animated: false)
            Async.after {
                let dependencies = SendMoneyDependencies(navigationController: navigation)
                self.coordinator = DefaultSendMoneyOperativeCoordinator(dependencies: dependencies)
                self.coordinator?.start()
            }
        })
    }
    
    struct SendMoneyDependencies: SendMoneyOperativeExternalDependenciesResolver {
        
        let navigationController: UINavigationController

        func resolve() -> UINavigationController {
            return navigationController
        }
        
        func resolve() -> AppConfigRepositoryProtocol {
            return MockAppConfigRepository(mockDataInjector: MockDataInjector())
        }
        
        func globalSearchCoordinator() -> Coordinator {
            return ToastCoordinator()
        }
        
        func privateMenuCoordinator() -> Coordinator {
            return ToastCoordinator()
        }
    }
    
    struct OnBoardingDependenciesImp: OnBoardingExternalDependencies {
        let navigationController: UINavigationController

        func resolve() -> UINavigationController {
            return navigationController
        }
        
        func resolveOnBoardingCustomStepView(for identifier: String, coordinator: StepsCoordinator<OnBoardingStep>) -> StepIdentifiable {
            return CustomViewController()
        }
    }
}

final class CustomViewController: UIViewController, StepIdentifiable {}
