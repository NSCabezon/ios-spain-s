class AccountModelView: ProductBaseModelView<Account, ItemProductGenericViewCell> {
    
    override init(_ product: Account, _ privateComponent: PresentationComponent) {
        super.init(product, privateComponent)
        home = .accounts
    }

    override func getName() -> String {
        return product.getAliasCamelCase()
    }
    
    override func getSubName() -> String {
        return product.getIBANShort()
    }
    
    override func getQuantity() -> String {
        return product.getAmountUI()
    }

    override var movements: Int? {
        return product.movements
    }
    
    override func configure(viewCell: ItemProductGenericViewCell) {
        updateMovements(cell: viewCell)
    }
    
    private func updateMovements(cell: ItemProductGenericViewCell) {
        if let movements = movements, movements > 0 {
            cell.setTransferCount(count: movements > 99 ? "99+": "\(movements)")
        } else {
            cell.setTransferCount(count: nil)
        }
    }
}
