class SelectablePensionViewModel: TableModelViewItem<SelectableProductViewCell> {
    let pension: Pension
    
    init(_ pension: Pension, _ privateComponent: PresentationComponent) {
        self.pension = pension
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: SelectableProductViewCell) {
        viewCell.alias = pension.getAlias()?.uppercased()
        viewCell.identifier = pension.getDetailUI()
        viewCell.amount = pension.getAmountUI()
    }
}
