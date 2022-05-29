class PortfolioProductHomePresenter: ProductHomePresenter {
    
    var type: PortfolioProductType = PortfolioProductType.transactionFunds
    var profileProducts: [PortfolioProduct] = []
    override var selectedProduct: GenericProduct? {
        didSet {
            let productProfile = PortfolioProductProfile(type: type, productsProfile: profileProducts, selectedProduct: selectedProduct, dependencies: dependencies, errorHandler: genericErrorHandler, delegate: self, shareDelegate: self)
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
