struct Insets {
    let left: Double
    let right: Double
    let top: Double
    let bottom: Double
}

class OperativeLabelTableModelView: TableModelViewItem<OperativeLabelTableViewCell> {
    
    let title: LocalizedStylableText
    let style: LabelStylist?
    let insets: Insets?
    let isHtml: Bool?
    let titleIdentifier: String?
    
    init(title: LocalizedStylableText, style: LabelStylist?, insets: Insets? = nil, isHtml: Bool? = nil, titleIdentifier: String? = nil, privateComponent: PresentationComponent) {
        self.title = title
        self.style = style
        self.insets = insets
        self.isHtml = isHtml
        self.titleIdentifier = titleIdentifier
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: OperativeLabelTableViewCell) {
        viewCell.style = style
        if isHtml != nil {
            viewCell.titleHtml = title.text
        } else {
            viewCell.title = title
        }
        if let titleIdentifier = titleIdentifier {
            viewCell.setAccessibilityIdentifiers(identifier: titleIdentifier)
        }
        viewCell.applyInsets(insets: insets)
    }
}
