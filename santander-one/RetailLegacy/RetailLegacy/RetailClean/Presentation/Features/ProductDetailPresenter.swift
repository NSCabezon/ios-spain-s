import CoreFoundationLib
import CoreDomain

protocol ProductDetailNavigatorProtocol: MenuNavigator {
    func goToProductDetail(product: GenericProductProtocol, productDetail: GenericProductProtocol?, _ productHome: PrivateMenuProductHome)
}

extension ProductDetailNavigatorProtocol {
    func goToProductDetail(product: GenericProductProtocol, productDetail: GenericProductProtocol?, _ productHome: PrivateMenuProductHome) {
        let productDetailPresenter = presenterProvider.productDetailPresenter
        productDetailPresenter.productHome = productHome
        productDetailPresenter.product = product
        if let productDetail = productDetail {
            productDetailPresenter.productDetail = productDetail
        }
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(productDetailPresenter.view, animated: true)
    }
}

class ProductDetailPresenter: PrivatePresenter<ProductDetailViewController, ProductDetailNavigatorProtocol, ProductDetailPresenterProtocol>, ProductDetailProfileDelegate {
    let productDetailHeader: (ProductDetailHeaderPresenter & ProductDetailProfileSeteable)!
    var productDetailInfo: (ProductDetailInfoPresenter & ProductDetailProfileSeteable)!
    var productDetailProfile: ProductDetailProfile?
    var productHome: PrivateMenuProductHome!
    var product: GenericProductProtocol?
    var productDetail: GenericProductProtocol?

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return productDetailProfile?.screenId
    }
    
    override func getTrackParameters() -> [String: String]? {
        return productDetailProfile?.getTrackParameters()
    }

    // MARK: -

    init(productDetailHeader: ProductDetailHeaderPresenter & ProductDetailProfileSeteable, productDetailInfo: ProductDetailInfoPresenter & ProductDetailProfileSeteable, sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: ProductDetailNavigatorProtocol) {
        self.productDetailHeader = productDetailHeader
        self.productDetailInfo = productDetailInfo
        
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        self.barButtons = [.menu]
    }
    
    override func loadViewData() {
        let productDetailProfileFactory = ProductDetailProfileFactory(product: product,
                                                                      productDetail: productDetail,
                                                                      productHome: productHome,
                                                                      errorHandler: genericErrorHandler,
                                                                      dependencies: dependencies,
                                                                      delegate: self,
                                                                      shareDelegate: self)
        if let productDetailProfile = productDetailProfileFactory.makeDetailProfile() {
            self.productDetailProfile = productDetailProfile
            productDetailHeader.productDetailProfile = productDetailProfile
            productDetailInfo.productHome = productHome
            productDetailInfo.productDetailProfile = productDetailProfile
            view.styledTitle = productDetailProfile.productTitle
        }   
    }
}

extension ProductDetailPresenter: Presenter {
    
}

extension ProductDetailPresenter: ProductDetailPresenterProtocol {
    var header: ViewControllerProxy {
        return productDetailHeader.view
    }
    
    var detail: ViewControllerProxy {
        return productDetailInfo.view
    }
    
}

extension ProductDetailPresenter: SideMenuCapable {
    var isSideMenuAvailable: Bool {
        return true
    }
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
}
