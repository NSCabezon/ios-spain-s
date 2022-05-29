import Operative
import UI
import CoreFoundationLib

enum EasyPayFinishingOption {
    case financing
    case globalPosition
}

final class EasyPayFinishingCoordinator: EasyPayFinishingCoordinatorProtocol {
    
    weak var navigationController: UINavigationController?
    private let resolver: DependenciesResolver
    
    private var navigator: EasyPayNavigatorDelegate {
        resolver.resolve()
    }
    
    init(navigationController: UINavigationController?, resolver: DependenciesResolver) {
        self.navigationController = navigationController
        self.resolver = resolver
    }
    
    func goToFinancing() {
        let navigatorProvider = resolver.resolve(for: EasyPayNavigatorProviderProtocol.self)
        navigatorProvider.easyPayNavigatorDelegate.goToFinancing()
        if let globalPositionVC = navigationController?.viewControllers.first, let lastVC: UIViewController = navigationController?.viewControllers.last {
            guard globalPositionVC != lastVC else { return }
            navigationController?.setViewControllers([globalPositionVC, lastVC], animated: false)
        }
    }
}

extension EasyPayFinishingCoordinatorProtocol {
    func goToGlobalPosition(_ navigationController: UINavigationController?) {
        navigationController?.popToRootViewController(animated: true)
    }
}

protocol EasyPayFinishingCoordinatorProtocol: OperativeFinishingCoordinator {
    var navigationController: UINavigationController? { get set }
    func goToFinancing()
}

extension EasyPayFinishingCoordinatorProtocol {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        guard let finishingOption: EasyPayFinishingOption = operative.container?.getOptional() else {
            if let sourceView = coordinator.sourceView {
                coordinator.navigationController?.popToViewController(sourceView, animated: true)
            } else {
                coordinator.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        switch finishingOption {
        case .globalPosition:
            self.goToGlobalPosition()
        case .financing:
            self.goToFinancing()
        }
    }
    
    func goToGlobalPosition() {
        if let baseMenuController = self.navigationController?.presentingViewController as? BaseMenuController,
            let navigationController = baseMenuController.currentRootViewController as? UINavigationController {
            navigationController.dismiss(animated: true, completion: {
                self.goToGlobalPosition(navigationController)
            })
        } else {
            self.goToGlobalPosition(self.navigationController)
        }
    }
}

public protocol EasyPayNavigatorDelegate: AnyObject {
    func goToFinancing()
}

public protocol EasyPayNavigatorProviderProtocol {
    var easyPayNavigatorDelegate: EasyPayNavigatorDelegate { get }
}
