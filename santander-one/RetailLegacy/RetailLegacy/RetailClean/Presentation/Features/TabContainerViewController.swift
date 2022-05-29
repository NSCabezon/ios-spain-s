import UIKit

protocol TabContainerPresenterProtocol: SideMenuCapable {
    func didSelectListOption(_ option: Int)
}

class TabContainerViewController: BaseViewController<TabContainerPresenterProtocol> {
    
    @IBOutlet weak var tabControlView: TabControlView!
    @IBOutlet weak var containerView: UIView!

    func setTabs(_ options: [(String?, LocalizedStylableText)]) {
        tabControlView.setOptions(options)
        
        tabControlView.didSelect = { [weak self] option in
            self?.didSelectOption(option)
        }
    }
    
    override class var storyboardName: String {
        return "Mailbox"
    }
    
    override func prepareView() {
        super.prepareView()
        show(barButton: .menu)
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    func setViewController(_ viewController: ViewControllerProxy) {
        let viewController = viewController.viewController
        guard let newView = viewController.view else {
            return
        }
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(viewController)
        containerView.addSubview(newView)
        newView.embedInto(container: containerView)
        newView.frame = containerView.frame
        viewController.didMove(toParent: self)
    }
    
    func remove(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    private func didSelectOption(_ option: Int ) {
        presenter.didSelectListOption(option)
    }
}

extension TabContainerViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}
