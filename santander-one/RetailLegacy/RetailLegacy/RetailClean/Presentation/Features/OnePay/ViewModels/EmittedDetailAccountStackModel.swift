class EmittedDetailAccountStackModel: StackItem<EmittedDetailAccountStackView> {
    private let account: Account
    
    init(_ account: Account, insets: Insets = Insets(left: 10, right: 10, top: 0, bottom: 3)) {
        self.account = account
        super.init(insets: insets)
    }
    
    override func bind(view: EmittedDetailAccountStackView) {
        view.name = account.getAliasUpperCase()
        view.identifier = account.getIBANShortLisboaStyle()
        view.amount = account.getAmount()?.getFormattedAmountUI()
    }
}
