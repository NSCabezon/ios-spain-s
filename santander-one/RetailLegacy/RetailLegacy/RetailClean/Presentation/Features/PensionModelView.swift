class PensionModelView: ProductBaseModelView<Pension, ItemProductGenericViewCell> {

    override func getName() -> String {
        return product.getAliasCamelCase()
    }
    
    override func getSubName() -> String {
        var productDescription = ""
        if  product.getDetailUI().count > 4 {
            productDescription = "***\(product.getDetailUI().substring(product.getDetailUI().count - 4) ?? "")"
        }
        return productDescription
    }
    
    override func getQuantity() -> String {
        return product.getAmountUI()
    }
    
    override init(_ product: Pension, _ privateComponent: PresentationComponent) {
        super.init(product, privateComponent)
        home = .pensions
    }
}
