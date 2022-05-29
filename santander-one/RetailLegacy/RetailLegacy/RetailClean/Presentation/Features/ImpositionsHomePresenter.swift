class ImpositionsHomePresenter: ProductHomePresenter {
    
    var profileProducts: [Imposition] = []

    override var selectedProduct: GenericProduct? {
        didSet {
            let productProfile = ImpositionProfile(impositionsProfile: profileProducts, selectedProduct: selectedProduct, dependencies: dependencies, errorHandler: genericErrorHandler, delegate: self, shareDelegate: self)
            productTransactions.productProfile = productProfile
            productTransactions.reloadContent(request: false)
            self.productProfile = productProfile
            productHeader.productProfile = productProfile
            let productTitle = productProfile.productTitle
            if productProfile.showNavigationInfo {
                view.setInfoTitle(productTitle)
            } else {
                view.styledTitle = productTitle
            }
        }
    }
}
