class DepositModelView: ProductBaseModelView<Deposit, ItemProductGenericViewCell> {

    override func getName() -> String {
        return product.getAliasCamelCase()
    }
    
    override func getSubName() -> String {
        var productDescription = ""
        if let detailUI = product.getDetailUI(), detailUI.count > 4 {
            productDescription = "***\(detailUI.substring(detailUI.count - 4) ?? "")"
        }
        return productDescription
    }
    
    override func getQuantity() -> String {
        return product.getAmountUI()
    }

    override init(_ product: Deposit, _ privateComponent: PresentationComponent) {
        super.init(product, privateComponent)
        home = .deposits
    }
}
