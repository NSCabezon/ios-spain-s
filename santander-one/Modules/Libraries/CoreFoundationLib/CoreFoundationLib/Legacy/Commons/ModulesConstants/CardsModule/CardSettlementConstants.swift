
public struct CardSettlementDetailPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/card/next_settlement"
    public enum Action: String {
        case postponeReceipt = "postpone_bill"
        case changePaymentMethod = "change_payment_method"
        case pdfExtract = "view_pdf_settlement"
        case shoppingMap = "view_purchase_map"
    }
    public init() {}
}

public struct CardSettlementListPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/card/next_settlement/transaction_list"
    public enum Action: String {
        case postponeReceipt = "postpone_bill"
        case changePaymentMethod = "change_payment_method"
        case pdfExtract = "view_pdf_settlement"
        case shoppingMap = "click_purchase_map"
    }
    public init() {}
}
