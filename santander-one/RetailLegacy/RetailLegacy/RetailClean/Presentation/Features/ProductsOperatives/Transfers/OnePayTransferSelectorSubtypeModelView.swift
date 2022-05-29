class OnePayTransferSelectorSubtypeModelView: TableModelViewItem<OnePayTransferSelectorSubtypeCell> {
    
    let subType: OnePayTransferSubType
    private let title: LocalizedStylableText
    private let icon: String
    private let items: [LocalizedStylableText]
    private let tooltipInfo: (title: LocalizedStylableText?, description: LocalizedStylableText?)?

    // MARK: - Public methods
    
    init(_ subType: OnePayTransferSubType, title: LocalizedStylableText, icon: String, items: [LocalizedStylableText], dependencies: PresentationComponent, tooltipInfo: (title: LocalizedStylableText?, description: LocalizedStylableText?)? = nil) {
        self.subType = subType
        self.title = title
        self.icon = icon
        self.items = items
        self.tooltipInfo = tooltipInfo
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: OnePayTransferSelectorSubtypeCell) {
        viewCell.setIcon(icon: icon)
        viewCell.setTitle(text: title)
        viewCell.setContent(texts: items)
        viewCell.setToolTipWith(title: tooltipInfo?.title, subtitle: tooltipInfo?.description)
    }
}
