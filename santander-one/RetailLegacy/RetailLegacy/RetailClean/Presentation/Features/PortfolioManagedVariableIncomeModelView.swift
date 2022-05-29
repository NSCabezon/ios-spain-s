class PortfolioManagedVariableIncomeModelView: ProductBaseModelView<Portfolio, ItemProductGenericViewCell> {
    
    override func getName() -> String {
        return product.getAliasCamelCase()
    }
    
    override func getSubName() -> String {
        return product.getDetailUI()
    }
    
    override func getQuantity() -> String {
        return product.getAmountUI()
    }
    
    override init(_ product: Portfolio, _ privateComponent: PresentationComponent) {
        super.init(product, privateComponent)
        home = .managedPortfolios
    }
}
