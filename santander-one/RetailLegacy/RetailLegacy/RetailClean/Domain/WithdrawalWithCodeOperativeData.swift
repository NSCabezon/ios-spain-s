class WithdrawalWithCodeOperativeData: ProductSelection<Card> {
    var cardDetail: CardDetail?
    var amounts: [String]?
    var cashWithDrawal: CashWithDrawal?
    var amount: Amount?
    
    init(card: Card?) {
        super.init(list: [], productSelected: card, titleKey: "tooldbar_title_withdrawCode", subTitleKey: "deeplink_label_selectOriginCard")
    }
    
    func updatePre(list: [Card]) {
        self.list = list
    }
    
    func update(cardDetail: CardDetail, amounts: [String]?) {
        self.cardDetail = cardDetail
        self.amounts = amounts
    }
}
