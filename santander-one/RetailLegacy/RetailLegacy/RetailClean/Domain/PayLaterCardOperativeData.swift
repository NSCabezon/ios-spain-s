struct PayLaterCard: OperativeParameter {
    let originCard: Card
    let cardDetail: CardDetail
    let percentageAmount: Amount
    let payLater: PayLater
    var amountToPayLater: Amount?
    var amountToDefer: Amount?
    
    init(originCard: Card, cardDetail: CardDetail, amountPercent: Amount, payLater: PayLater) {
        self.originCard = originCard
        self.cardDetail = cardDetail
        self.percentageAmount = amountPercent
        self.payLater = payLater
    }
}

class PayLaterCardOperativeData: ProductSelection<Card> {
    var payLaterCard: PayLaterCard?
    
    init(card: Card?) {
        super.init(list: [], productSelected: card, titleKey: "toolbar_title_payLater", subTitleKey: "deeplink_label_selectOriginCard")
    }
    
    func updatePre(cards: [Card]) {
        self.list = cards
    }
}
