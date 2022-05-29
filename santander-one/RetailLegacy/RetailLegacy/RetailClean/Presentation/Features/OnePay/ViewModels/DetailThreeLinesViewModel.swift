class DetailThreeLinesViewModel: TableModelViewItem<DetailThreeLinesTableViewCell> {
    
    private let title: LocalizedStylableText
    private let info: String?
    private let amount: Amount?
    private let isFirst: Bool
    private let isLast: Bool

    init(_ title: LocalizedStylableText, amount: Amount?, isFirst: Bool, isLast: Bool, info: String?, _ privateComponent: PresentationComponent) {
        self.title = title
        self.info = info
        self.amount = amount
        self.isFirst = isFirst
        self.isLast = isLast
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: DetailThreeLinesTableViewCell) {
        viewCell.setTitle(title)
        viewCell.setAmount(amount?.getFormattedAmountUI())
        viewCell.setDescription(info)
        viewCell.isFirst = isFirst
        viewCell.isLast = isLast
    }
}
