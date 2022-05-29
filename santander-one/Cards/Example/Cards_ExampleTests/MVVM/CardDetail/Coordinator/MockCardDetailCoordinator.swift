import CoreFoundationLib
import UI
import CoreDomain
@testable import Cards

final class MockCardDetailCoordinator: CardDetailCoordinator {
   
    
    var dataBinding: DataBinding
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var shareCalled: Bool = false
    var openMenuCalled: Bool = false
    var startCalled: Bool = false
    var activeCardCalled: Bool = false
    var showPANCalled: Bool = false
    
    
    init() {
        dataBinding = DataBindingObject()
        childCoordinators = []
    }

    func start() {
        startCalled = true
    }
    func openMenu() {
        openMenuCalled = true
    }
    
    func activeCard(card: CardRepresentable) {
        activeCardCalled = true
    }
    
    func showPAN() {
        showPANCalled = true
    }
    
    func share(_ shareable: Shareable) {
        shareCalled = true
    }
    
}
