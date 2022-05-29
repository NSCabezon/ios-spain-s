class FundSubscriptionConfirmationFundViewModel: TableModelViewItem<GenericConfirmationTableViewCell> {
    
    private var fund: Fund
    
    init(_ fund: Fund, _ privateComponent: PresentationComponent) {
        self.fund = fund
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: GenericConfirmationTableViewCell) {
        viewCell.name = fund.getAlias()
        viewCell.amount = fund.getAmountUI()
        viewCell.amountInfo = nil
    }
}
