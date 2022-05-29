class SelectableFundViewModel: TableModelViewItem<SelectableProductViewCell> {
    
    var fund: Fund
    
    init(_ fund: Fund, _ privateComponent: PresentationComponent) {
        self.fund = fund
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: SelectableProductViewCell) {
        viewCell.alias = fund.getAlias()?.uppercased()
        viewCell.identifier = fund.getDetailUI()
        viewCell.amount = fund.getAmountUI()
    }
    
}
