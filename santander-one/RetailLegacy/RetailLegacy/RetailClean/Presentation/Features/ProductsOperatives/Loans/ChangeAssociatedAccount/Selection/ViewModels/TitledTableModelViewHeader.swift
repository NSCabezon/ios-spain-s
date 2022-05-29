class TitledTableModelViewHeader: TableModelViewHeader<TitledTableHeader> {
    
    var title: LocalizedStylableText?
    var insets: Insets
    var titleIdentifier: String?
    
    init(insets: Insets = Insets(left: 11, right: 10, top: 15, bottom: 6)) {
        self.insets = insets
    }
    
    override func bind(viewHeader: TitledTableHeader) {
        viewHeader.title = title
        viewHeader.applyInsets(insets: self.insets)
        viewHeader.setTitleIdentifier(titleIdentifier)
    }
}
