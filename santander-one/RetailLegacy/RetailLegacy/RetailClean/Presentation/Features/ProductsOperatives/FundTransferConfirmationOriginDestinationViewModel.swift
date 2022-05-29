class FundTransferConfirmationOriginDestinationViewModel: TableModelViewItem<FundTransferConfirmationViewCell> {
    
    private var fund: Fund
    private var originDestination: String

    init(_ fund: Fund, originDestination: String, _ privateComponent: PresentationComponent) {
        self.fund = fund
        self.originDestination = originDestination
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: FundTransferConfirmationViewCell) {
        viewCell.name = fund.getAlias()
        viewCell.amount = fund.getAmountUI()
        viewCell.info = originDestination
    }
}
