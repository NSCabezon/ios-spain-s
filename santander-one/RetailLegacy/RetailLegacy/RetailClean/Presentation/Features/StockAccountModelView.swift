class StockAccountModelView: ProductBaseModelView<StockAccount, ItemProductGenericViewCell> {

    override func getName() -> String {
        return product.getAliasCamelCase()
    }
    
    override func getSubName() -> String {
        var productDescription = ""
        if product.getDetailUI().count > 4 {
            productDescription = "***\(product.getDetailUI().substring(product.getDetailUI().count - 4) ?? "")"
        }
        return productDescription
    }
    
    override func getQuantity() -> String {
        return product.getAmountUI()
    }
    
    override init(_ product: StockAccount, _ privateComponent: PresentationComponent) {
        super.init(product, privateComponent)
        home = .stocks
    }
}
