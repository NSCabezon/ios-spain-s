class InsuranceModelView: ProductBaseModelView<InsuranceProtection, ItemProductGenericViewCell> {

    override func getName() -> String {
        return product.getAliasCamelCase()
    }
    
    override func getSubName() -> String {
        return product.getDetailUI()
    }
    
    override func getQuantity() -> String {
        return ""
    }
    
    override init(_ product: InsuranceProtection, _ privateComponent: PresentationComponent) {
        super.init(product, privateComponent)
        home = .insuranceProtection
    }
}
