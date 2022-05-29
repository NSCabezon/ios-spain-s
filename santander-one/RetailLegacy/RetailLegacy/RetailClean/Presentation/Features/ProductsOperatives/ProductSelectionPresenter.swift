import Foundation
import CoreFoundationLib


class ProductSelectionPresenter<Product: GenericProduct, Navigator>: PrivatePresenter<ProductSelectionViewController, Navigator, ProductSelectionPresenterProtocol>, ProductSelectionPresenterProtocol {
    
    var products: [Product]
    private let titleKey: String
    private let sectionTitleKey: String
    
    var tooltipMessage: LocalizedStylableText?
    
    init(products: [Product], titleKey: String, sectionTitleKey: String, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: Navigator) {
        self.products = products
        self.titleKey = titleKey
        self.sectionTitleKey = sectionTitleKey
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        self.setTitle()
        showProducts(sectionTitleKey: sectionTitleKey)
    }
    
    var progressBarBackgroundStyle: ProductSelectionProgressStyle {
        return .white
    }
    
    // MARK: - ProductSelectionPresenterProtocol
    
    func selected(index: Int) {
        fatalError("This method has to be overrided")
    }
    
    func setTitle() {
        set(title: titleKey)
    }
    
    func getTitle() -> String? {
        return titleKey
    }
}
