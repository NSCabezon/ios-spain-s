
public struct GlobalSearchPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/global_seach"
    
    public enum Action: String {
        case search = "search"
        case reportDuplicatedMovement = "report_duplicated_transaction"
        case returnBill = "return_bill"
        case reuseTransfer = "reuse_transfer"
        case offCard = "turnoff_card"
        case action = "click_tip"
    }
    public init() {}
}
