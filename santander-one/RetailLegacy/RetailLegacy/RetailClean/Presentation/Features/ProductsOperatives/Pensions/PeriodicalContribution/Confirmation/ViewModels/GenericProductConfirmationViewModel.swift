class GenericProductConfirmationViewModel<Product: GenericProduct>: TableModelViewItem<GenericConfirmationTableViewCell> {
    var product: Product
    
    init(_ product: Product, _ privateComponent: PresentationComponent) {
        self.product = product
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: GenericConfirmationTableViewCell) {
        viewCell.name = product.getAlias()
        viewCell.amount = product.getAmountUI()
        viewCell.amountInfo = nil
    }
}
