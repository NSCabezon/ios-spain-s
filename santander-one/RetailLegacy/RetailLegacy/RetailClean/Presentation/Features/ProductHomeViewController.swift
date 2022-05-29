import UIKit
import CoreFoundationLib
import UI
import CoreDomain

protocol HomeViewSection {
    
}

protocol ProductHomePresenterProtocol {
    var header: ViewControllerProxy { get }
    var detail: ViewControllerProxy { get }
    var getMenuOption: PrivateMenuOptions? { get }
    func toggleSideMenu()
    func showInfo()
    func dismiss()
    func viewWillDisappear()
}

class ProductHomeViewController: BaseViewController<ProductHomePresenterProtocol> {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var detailView: UIView!
    
    override class var storyboardName: String {
        return "ProductHome"
    }
    
    override func prepareView() {
        super.prepareView()
        setDetail(viewController: presenter.detail.viewController)
        setHeader(viewController: presenter.header.viewController)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isBeingPresented || isMovingToParent { // View is being presented
            self.setupNavigationBar()
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isBeingPresented && !isMovingToParent { // Returned from detail view
            self.setupNavigationBar()
        }
    }

    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: self.title ?? "")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(showMenu)))
        builder.build(on: self, with: nil)
    }
    
    func setHeader(viewController: UIViewController) {
        setViewController(viewController, to: .header)
    }
    
    func setDetail(viewController: UIViewController) {
        setViewController(viewController, to: .detail)
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func setInfoTitle(_ title: LocalizedStylableText) {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(actionInfo), for: .touchUpInside)
        navigationItem.setInfoTitle(title, button: button)
        styledTitle = title
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    @objc func actionInfo() {
        presenter.showInfo()
    }

    @objc func dismissViewController() {
        self.presenter.dismiss()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            presenter.viewWillDisappear()
        }
    }
}

// MARK: - RootMenuController

extension ProductHomeViewController: RootMenuController {
    
    var isSideMenuAvailable: Bool {
        return true
    }
    
}

// MARK: - Helpers
extension ProductHomeViewController {
    
    enum ViewPosition {
        case header
        case detail
    }
    
    private func setViewController(_ viewController: UIViewController, to position: ViewPosition) {
        guard let newView = viewController.view,
            let destinationView = position == .header ? headerView : detailView else {
            return
        }
        
        addChild(viewController)
        newView.frame = destinationView.bounds
        destinationView.addSubview(newView)
        viewController.didMove(toParent: self)
    }
    
}

extension ProductHomeViewController: HighlightedMenuProtocol {
    func getOption() -> PrivateMenuOptions? {
        return presenter.getMenuOption
    }
}
