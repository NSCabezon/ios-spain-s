class SelectableProductViewModel: TableModelViewItem<SelectableProductViewCell> {
    let product: GenericProduct
    
    init(_ product: GenericProduct, _ privateComponent: PresentationComponent) {
        self.product = product
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: SelectableProductViewCell) {
        viewCell.alias = product.getAlias()?.uppercased()
        viewCell.identifier = product.getDetailUI()
        viewCell.amount = product.getAmountUI()
    }
}
