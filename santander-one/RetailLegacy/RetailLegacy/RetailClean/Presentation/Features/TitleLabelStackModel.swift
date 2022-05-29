class TitleLabelStackModel: StackItem<TitleLabelStackView> {
    private let title: LocalizedStylableText
    private let numberOfLines: Int?
    private let titleStyle: TitleLabelStackStyle
    private let identifier: String?
    
    init(title: LocalizedStylableText, numberOfLines: Int? = nil, identifier: String? = nil, titleStyle: TitleLabelStackStyle = .title, insets: Insets = Insets(left: 11, right: 10, top: 15, bottom: 6)) {
        self.title = title
        self.numberOfLines = numberOfLines
        self.titleStyle = titleStyle
        self.identifier = identifier
        super.init(insets: insets)
    }
    
    override func bind(view: TitleLabelStackView) {
        view.setStyle(titleStyle)
        view.setTitle(title: title, accessibilityIdentifier: accessibilityIdentifier)
        if let numberOfLines = numberOfLines {
            view.setTitleLines(numberOfLines)
        }
        if let identifier = identifier { view.setAccessbilityIdentifiers(identifier: identifier) }
    }
}
