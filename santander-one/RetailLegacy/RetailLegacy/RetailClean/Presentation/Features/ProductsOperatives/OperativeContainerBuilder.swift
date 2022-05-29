import UIKit

class OperativeContainerBuilder {
    
    private let presenterProvider: PresenterProvider
    private let presentationComponent: PresentationComponent
    
    init(presenterProvider: PresenterProvider, presentationComponent: PresentationComponent) {
        self.presenterProvider = presenterProvider
        self.presentationComponent = presentationComponent
    }
    
    func operativeContainer(for operative: Operative, with parameters: [OperativeParameter], fromView source: UIViewController) -> OperativeContainerProtocol? {
        return OperativeContainer(operative: operative, repository: parameters, dependencies: presentationComponent, presenterProvider: presenterProvider, operativeContainerNavigator: OperativeContainerNavigator(sourceView: source, dependencies: presentationComponent))
    }
}
