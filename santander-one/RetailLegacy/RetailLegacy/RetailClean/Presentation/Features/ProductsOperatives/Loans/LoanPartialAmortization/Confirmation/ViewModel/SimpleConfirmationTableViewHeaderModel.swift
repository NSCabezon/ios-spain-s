class SimpleConfirmationTableViewHeaderModel: TableModelViewItem<ConfirmationItemViewCell> {
    
    let descriptionText: LocalizedStylableText
    let valueText: String
    let isLast: Bool
    let topSpace: Double
    let inputIdentifier: String?
    
    init(_ descriptionText: LocalizedStylableText, _ valueText: String, inputIdentifier: String? = nil, _ isLast: Bool = false, topSpace: Double = 0, _ privateComponent: PresentationComponent) {
        self.descriptionText = descriptionText
        self.valueText = valueText
        self.isLast = isLast
        self.topSpace = topSpace
        self.inputIdentifier = inputIdentifier
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: ConfirmationItemViewCell) {
        viewCell.isFirst = true
        viewCell.isLast = isLast
        viewCell.descriptionText = descriptionText
        viewCell.setTopSpace(space: topSpace)
        viewCell.valueText = valueText
        if let inputIdentifier = inputIdentifier {
            viewCell.setAccessibilityIdentifiers(identifiers: ("\(inputIdentifier)_view", "\(inputIdentifier)_title", "\(inputIdentifier)_value"))
        }
    }
}
