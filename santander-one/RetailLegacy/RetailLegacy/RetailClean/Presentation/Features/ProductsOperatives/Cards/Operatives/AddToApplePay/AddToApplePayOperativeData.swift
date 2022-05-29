class AddToApplePayOperativeData: ProductSelection<Card> {
    var cardDetail: CardDetail?
    var card: Card? {
        get {  return self.productSelected }
        set { self.productSelected = newValue}
    }
    
    init(cards: [Card], card: Card?) {
        super.init(
            list: cards,
            productSelected: card,
            titleKey: "toolbar_title_addApplePay",
            subTitleKey: ""
        )
    }
}
