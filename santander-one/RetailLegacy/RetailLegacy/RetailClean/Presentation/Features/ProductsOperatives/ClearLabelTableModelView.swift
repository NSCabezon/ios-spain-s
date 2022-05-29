class ClearLabelTableModelView: TableModelViewItem<OperativeLabelTableViewCell> {
    
    let title: LocalizedStylableText
    let style: LabelStylist?
    let insets: Insets?
    let isHtml: Bool?
    let inputIdentifier: String?
    
    init(title: LocalizedStylableText, inputIndentifier: String? = nil, style: LabelStylist?, insets: Insets? = nil, isHtml: Bool? = false, privateComponent: PresentationComponent) {
        self.title = title
        self.style = style
        self.insets = insets
        self.isHtml = isHtml
        self.inputIdentifier = inputIndentifier
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: OperativeLabelTableViewCell) {
        viewCell.style = style
        viewCell.title = title
        viewCell.applyInsets(insets: insets)
        if let inputIdentifier = inputIdentifier {
            viewCell.setAccessibilityIdentifiers(identifier: inputIdentifier)
        }
    }
}
