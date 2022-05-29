class SavingsInsuranceModelView: ProductBaseModelView<InsuranceSaving, ItemProductGenericViewCell> {

    let isBalanceEnabled: Bool
    
    override func getName() -> String {
        return product.getAliasCamelCase()
    }
    
    override func getSubName() -> String {
        return product.getDetailUI()
    }
    
    override func getQuantity() -> String {
        guard isBalanceEnabled == true else { return "" }
        return product.getAmountUI()
    }

    init(_ product: InsuranceSaving, _ privateComponent: PresentationComponent, isBalanceEnabled: Bool) {
        self.isBalanceEnabled = isBalanceEnabled
        super.init(product, privateComponent)
        home = .insuranceSavings
    }
}
