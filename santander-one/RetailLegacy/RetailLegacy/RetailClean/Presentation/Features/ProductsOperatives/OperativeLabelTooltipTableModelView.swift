final class OperativeLabelTooltipTableModelView: TableModelViewItem<OperativeLabelTooltipTableViewCell> {
    
    let tooltipText: LocalizedStylableText
    let title: LocalizedStylableText
    let style: LabelStylist?
    let insets: Insets?
    let isHtml: Bool?
    var titleIdentifier: String?
    
    init(title: LocalizedStylableText,
         style: LabelStylist?,
         insets: Insets? = nil,
         isHtml: Bool? = nil,
         privateComponent: PresentationComponent,
         tooltipText: LocalizedStylableText,
         titleIdentifier: String? = nil) {
        self.tooltipText = tooltipText
        self.title = title
        self.style = style
        self.insets = insets
        self.isHtml = isHtml
        self.titleIdentifier = titleIdentifier
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: OperativeLabelTooltipTableViewCell) {
        viewCell.style = style
        viewCell.tooltipText = tooltipText.text
        if isHtml != nil {
            viewCell.titleHtml = title.text
        } else {
            viewCell.title = title
        }
        viewCell.applyInsets(insets: insets)
        if let titleIdentifier = titleIdentifier {
            viewCell.setAccessibilityIdentifiers(identifier: titleIdentifier)
        }
    }
}
