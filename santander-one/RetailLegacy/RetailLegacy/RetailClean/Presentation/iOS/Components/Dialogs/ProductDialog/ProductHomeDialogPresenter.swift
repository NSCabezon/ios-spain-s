import CoreFoundationLib

class ProductHomeDialogPresenter: PrivatePresenter<ProductHomeDialogViewController, ProductHomeNavigatorProtocol, ProductHomeDialogPresenterProtocol>, ProductHomeDialogPresenterProtocol {
    
    var options: [ProductOption]
    
    init(options: [ProductOption], sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: ProductHomeNavigatorProtocol) {
        self.options = options
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
}
