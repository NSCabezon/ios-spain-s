import UIKit

protocol OperativeContainerNavigatorProtocol: class {
    var firstViewController: UIViewController? { get set }
    var currentViewController: UIViewController? { get }
    var navigationController: NavigationController? { get }
    var sourceView: UIViewController? { get set }
    var operativeContainer: OperativeContainer? { get set }
    func presentModal(_ step: OperativeStepPresenterProtocol)
    func push(_ step: OperativeStepPresenterProtocol)
    func back()
    func backOnePay(_ list: [Account])
}

class OperativeContainerNavigator: OperativeContainerNavigatorProtocol {
    
    // MARK: - Public
    
    weak var firstViewController: UIViewController?
    var currentViewController: UIViewController? {
        return operativeContainer?.currentPresenter?.stepView.viewController
    }
    var navigationController: NavigationController? {
        return sourceView?.navigationController as? NavigationController
    }
    weak var operativeContainer: OperativeContainer?
    weak var sourceView: UIViewController?
    
    // MARK: - Private
    
    private let dependencies: PresentationComponent
    
    // MARK: - Public methods
    
    init(sourceView: UIViewController, dependencies: PresentationComponent) {
        self.sourceView = sourceView
        self.dependencies = dependencies
    }
    
    func back() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //Temporal function only to go back in Transfer when the new Lisboa design
    func backOnePay(_ list: [Account]) {
        guard var viewControllers = self.sourceView?.navigationController?.viewControllers else { return }
        let operativeViews = viewControllers.filter({ $0 is OnePayAccountSelectorViewController })
        if operativeViews.count > 0 {
            guard let indexInNavigation = viewControllers.firstIndex(of: operativeViews[0]) else {
                return assertionFailure("The operative have to be OperativeBackViewController")
            }
            let viewToPop = viewControllers[indexInNavigation]
            viewControllers.remove(at: indexInNavigation+1)
            self.sourceView?.navigationController?.viewControllers = viewControllers
            self.navigationController?.popToViewController(viewToPop, animated: true)
        } else {
            //Delete all View Controller of step of operatives and start the operative again
            let operativeViews = viewControllers.filter({ $0 is OnePayTransferSelectorViewController })
            guard let indexInNavigation = viewControllers.firstIndex(of: operativeViews[0]) else { return }
            viewControllers.removeSubrange(indexInNavigation...viewControllers.count-1)
            self.sourceView?.navigationController?.viewControllers = viewControllers
            
            let operativeData = OnePayTransferOperativeData(account: nil)
            operativeData.list = list
            operativeData.isBackToOriginEnabled = true
            self.operativeContainer?.saveParameter(parameter: operativeData)
            self.operativeContainer?.rebuildSteps()
            self.operativeContainer?.start()
        }
    }
    
    func presentModal(_ step: OperativeStepPresenterProtocol) {
        let viewController = step.stepView.viewController
        if firstViewController == nil {
            firstViewController = viewController
        }
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .overCurrentContext
        self.navigationController?.viewControllers.last?.present(viewController, animated: true, completion: nil)
    }
    
    func push(_ step: OperativeStepPresenterProtocol) {
        let viewController = step.stepView.viewController
        if firstViewController == nil {
            firstViewController = viewController
        }
        let operativeView = sourceView?.navigationController?.viewControllers.last as? UIViewController & OperativeStepViewProtocol
        self.navigationController?.blockingPushViewController(viewController, animated: true) {
            guard let operativeView = operativeView, !operativeView.operativePresenter.isBackable else {
                return
            }
            guard let index = self.sourceView?.navigationController?.viewControllers.firstIndex(of: operativeView) else {
                return
            }
            self.sourceView?.navigationController?.viewControllers.remove(at: index)
        }
    }
}
