import UIKit

protocol OperativesNavigatorProtocol {
    var presenterProvider: PresenterProvider { get }
    var drawer: BaseMenuViewController { get }
    
    func goToOperative(_ operative: Operative, withParameters parameters: [OperativeParameter], dependencies: PresentationComponent)
    func appendOperative(_ operative: Operative, dependencies: PresentationComponent) -> OperativeContainerProtocol?
    func setRightEdgePanGesture(enabled: Bool)
}

extension OperativesNavigatorProtocol {
    func goToOperative(_ operative: Operative, withParameters parameters: [OperativeParameter], dependencies: PresentationComponent) {
        guard let navigationController = drawer.currentRootViewController as? UINavigationController, let last = navigationController.viewControllers.last else {
            return
        }
        if let container = OperativeContainerBuilder(presenterProvider: presenterProvider, presentationComponent: dependencies).operativeContainer(for: operative, with: parameters, fromView: last) {
            container.start()
        }
    }
    
    func appendOperative(_ operative: Operative, dependencies: PresentationComponent) -> OperativeContainerProtocol? {
        guard let navigationController = drawer.currentRootViewController as? UINavigationController, let last = navigationController.viewControllers.last else {
            return nil
        }
        return OperativeContainerBuilder(presenterProvider: presenterProvider, presentationComponent: dependencies).operativeContainer(for: operative, with: [], fromView: last)
    }
    
    func setRightEdgePanGesture(enabled: Bool) {
        drawer.setRightEdgePanGesture(enabled: enabled)
    }
}
