
public struct WhatsNewPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "whatsnew"
    public enum Action: String {
        case updateApp = "actualizar_app"
        case viewPromotion = "view_promotion"
        case selectContent = "select_content"
    }
    public init() {}
}

public struct WhatsNewPullOffers {
    public static let operationInfo = "WHATSNEW_OPERATION_INFO"
    public static let recobro = "WHATSNEW_RECOBRO"
    public static let contractsInbox = "WHATSNEW_BUZON_CONTRATOS"
    public static let agentMessage = "WHATSNEW_MESSAGE_OFFER"
    public static let preconceived = "WHATSNEW_PRECON"
    public static let noPreconceived = "WHATSNEW_NO_PRECON"
}
