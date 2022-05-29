class BillsAndTaxesTypeSelectorModelView: TableModelViewItem<OnePayTransferSelectorSubtypeCell> {
    let type: BillsAndTaxesTypeOperative
    private let title: LocalizedStylableText
    private let icon: String
    private let items: [LocalizedStylableText]
    
    // MARK: - Public methods
    
    init(_ type: BillsAndTaxesTypeOperative, title: LocalizedStylableText, icon: String, items: [LocalizedStylableText], dependencies: PresentationComponent) {
        self.type = type
        self.title = title
        self.icon = icon
        self.items = items
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: OnePayTransferSelectorSubtypeCell) {
        viewCell.setIcon(icon: icon)
        viewCell.setTitle(text: title)
        viewCell.setContent(texts: items)
        viewCell.setToolTipWith(title: nil, subtitle: nil)
    }
}
