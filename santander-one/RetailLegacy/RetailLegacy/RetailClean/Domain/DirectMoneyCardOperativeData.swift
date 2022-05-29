class DirectMoneyCardOperativeData: ProductSelection<Card> {
    
    var card: Card? {
        get {
            return self.productSelected
        }
        set {
            self.productSelected = newValue
        }
    }
    var directMoney: DirectMoney?
    var cardDetail: CardDetail?
    var iban: IBAN?
    var launchedFrom: OperativeLaunchedFrom
    var account: Account?
    var amount: Amount?
    var directMoneyValidate: DirectMoneyValidate?
    
    init(cards: [Card], card: Card?, launchedFrom: OperativeLaunchedFrom) {
        self.launchedFrom = launchedFrom
        super.init(list: cards, productSelected: card, titleKey: "toolbar_title_directMoney", subTitleKey: "deeplink_label_selectOriginCard")
    }
}
