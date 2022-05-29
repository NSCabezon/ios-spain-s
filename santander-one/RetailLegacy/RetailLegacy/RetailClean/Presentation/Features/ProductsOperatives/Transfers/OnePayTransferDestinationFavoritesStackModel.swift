class OnePayTransferDestinationFavoritesStackModel: StackItem<OnePayTransferDestinationFavoritesStackView> {
    private let title: LocalizedStylableText
    var valueAction: (() -> Void)?
    
    init(title: LocalizedStylableText, insets: Insets = Insets(left: 11, right: 11, top: 8, bottom: 8)) {
        self.title = title
        super.init(insets: insets)
    }
    
    override func bind(view: OnePayTransferDestinationFavoritesStackView) {
        view.setTitle(text: title)
        view.valueAction = valueAction
    }
}
