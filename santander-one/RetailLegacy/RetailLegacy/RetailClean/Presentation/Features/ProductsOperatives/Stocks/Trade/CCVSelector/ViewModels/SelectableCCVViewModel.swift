class SelectableCCVViewModel: TableModelViewItem<SelectableProductViewCell> {
    
    var stockAccount: StockAccount
    
    init(_ stockAccount: StockAccount, _ privateComponent: PresentationComponent) {
        self.stockAccount = stockAccount
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: SelectableProductViewCell) {
        viewCell.alias = stockAccount.getAlias().uppercased()
        viewCell.identifier = stockAccount.getDetailUI()
        viewCell.amount = stockAccount.getAmountUI()
    }
    
}
