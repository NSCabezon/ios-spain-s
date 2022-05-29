class CardLimitManagementOperativeData: ProductSelection<Card> {
    
    var cardLimit: CardLimit?
    
    init(card: Card?) {
        super.init(list: [], productSelected: card, titleKey: "toolbar_title_limitsModifyCard", subTitleKey: "deeplink_label_selectOriginCard")
    }
    
    func updatePre(cards: [Card]) {
        self.list = cards
    }
}

enum CardLimit {
    case credit(atm: Amount)
    case debit(shopping: Amount, atm: Amount)
}
