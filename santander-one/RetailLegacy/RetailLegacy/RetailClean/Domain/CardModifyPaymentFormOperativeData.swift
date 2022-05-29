import Foundation

struct CardModifyPaymentForm {
    let card: Card
    var cardDetail: CardDetail?
    // New Payment method selected by user
    var newPaymentMethodStatus: PaymentMethodStatus?
    // Amount or percentage selected by suer
    var amount: Amount?
    // Old Amount or percentage selected by suer
    var oldAmount: Amount?
    // Current Payment, old payment
    var currentChangePayment: ChangePayment?
    // PaymentMethod selected by user
    var newPaymentMethod: PaymentMethod?
    // Old PaymentMethod selected by user
    var oldPaymentMethod: PaymentMethod?
    
    init(card: Card, cardDetail: CardDetail?, currentChangePayment: ChangePayment?, newPaymentMethodStatus: PaymentMethodStatus?) {
        self.card = card
        self.cardDetail = cardDetail
        self.currentChangePayment = currentChangePayment
        self.newPaymentMethodStatus = newPaymentMethodStatus
    }
}

class CardModifyPaymentFormOperativeData: ProductSelection<Card> {
    var cardModifyPaymentForm: CardModifyPaymentForm?
    
    init(card: Card?) {
        super.init(list: [], productSelected: card, titleKey: "toolbar_title_changeWayToPay", subTitleKey: "deeplink_label_selectOriginCard")
    }
    
    func updatePre(cards: [Card]) {
        self.list = cards
    }
}
