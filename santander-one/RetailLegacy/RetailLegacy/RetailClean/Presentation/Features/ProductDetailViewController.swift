import UIKit

protocol ProductDetailPresenterProtocol {
    var header: ViewControllerProxy { get }
    var detail: ViewControllerProxy { get }
    func toggleSideMenu()
    var isSideMenuAvailable: Bool { get }
}

class ProductDetailViewController: BaseViewController<ProductDetailPresenterProtocol> {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var detailView: UIView!
    
    override class var storyboardName: String {
        return "ProductDetail"
    }
    
    override func prepareView() {
        super.prepareView()
        setDetail(viewController: presenter.detail.viewController)
        setHeader(viewController: presenter.header.viewController)
        if presenter.isSideMenuAvailable == true {
            self.show(barButton: .menu)
        }
    }
    
    private func setHeader(viewController: UIViewController) {
        setViewController(viewController, to: .header)
    }
    
    private func setDetail(viewController: UIViewController) {
        setViewController(viewController, to: .detail)
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
}

// MARK: - RootMenuController
extension ProductDetailViewController: RootMenuController {
    
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
    
}

// MARK: - Helpers
extension ProductDetailViewController {
    
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
