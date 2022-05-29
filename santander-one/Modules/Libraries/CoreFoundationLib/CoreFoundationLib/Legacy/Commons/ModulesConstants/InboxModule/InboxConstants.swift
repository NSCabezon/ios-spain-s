
public struct InboxConstant {
    public static let enableOnlineMessagesInbox = "enableOnlineMessagesInbox"
    public static let onlineMessagesInboxUrl = "onlineMessagesInboxUrl"
    public static let pdfMessage = "toolbar_title_pdfMessages"
    public static let token = "token"
}

public struct InboxPullOffers {
    public static let inboxContractSlider = "BUZON_CONTRATOS_CARRUSEL"
    public static let privateBankStatement = "BUZON_EXTRACTOS"
    public static let inboxSetup = "INBOX_SETUP"
    public static let inboxContract = "BUZON_CONTRATOS"
    public static let inboxMessages = "BUZON_CORRESPONDENCIA"
    public static let inboxDocumentation = "INBOX_DOCUMENTARY_MANAGEMENT"
    public static let inboxFioc = "BUZON_CORRESPONDENCIA_FIOC"
}

public struct InboxHomePage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/mailbox/notification"
    
    public enum Action: String {
        case onlineInbox = "correspondencia_online"
        case privateBankStatement = "extractos_banca_privada"
        case notifications = "configura_alertas"
        case contracts = "contratos"
        case personalDocuments = "gestion_documentos_personal"
        case tapOnNotifications = "tap_notif_inbox"
    }
    public init() {}
}

public struct InboxNotificationPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/mailbox/notification"
    public enum Action: String {
        case deleteSwipe = "borrar_swipe"
        case selectAll = "seleccionar_todo"
        case delete = "borrar"
    }
    public init() {}
}
