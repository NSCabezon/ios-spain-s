class LinkWebViewCellModel: TableModelViewItem<LinkWebViewTableViewCell> {
    private var linkTouch: (() -> Void)?
    private let title: LocalizedStylableText
    
    init(title: LocalizedStylableText, linkTouch: (() -> Void)? = nil, privateComponent: PresentationComponent) {
        self.title = title
        self.linkTouch = linkTouch
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: LinkWebViewTableViewCell) {
        viewCell.setTitle(title)
        viewCell.delegate = self
    }
}

extension LinkWebViewCellModel: LinkWebViewTableViewDelegate {
    func linkDidSelect() {
        linkTouch?()
    }
}
