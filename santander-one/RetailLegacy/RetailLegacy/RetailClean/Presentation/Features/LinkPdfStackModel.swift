class LinkPdfStackModel: StackItem<LinkPdfStackView> {
    private var linkTouch: (() -> Void)?
    private let title: LocalizedStylableText

    init(title: LocalizedStylableText, insets: Insets = Insets(left: 11, right: 10, top: 0, bottom: 0), linkTouch: (() -> Void)? = nil) {
        self.title = title
        self.linkTouch = linkTouch
        super.init(insets: insets)
    }
    
    override func bind(view: LinkPdfStackView) {
        view.setTitle(title)
        view.delegate = self
    }
}

extension LinkPdfStackModel: LinkPdfStackViewDelegate {
    func linkStackViewDidSelect() {
        linkTouch?()
    }
}
