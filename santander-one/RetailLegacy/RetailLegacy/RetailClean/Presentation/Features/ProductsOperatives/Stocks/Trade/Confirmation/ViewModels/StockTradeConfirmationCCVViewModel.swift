class StockTradeConfirmationCCVViewModel: TableModelViewItem<GenericConfirmationTableViewCell> {
    
    private var stockAccount: StockAccount
    
    init(_ stockAccount: StockAccount, _ privateComponent: PresentationComponent) {
        self.stockAccount = stockAccount
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: GenericConfirmationTableViewCell) {
        viewCell.name = stockAccount.getAliasUpperCase()
        viewCell.amount = stockAccount.getAmountUI()
        viewCell.identifier = stockAccount.getContractShort()
    }
}
