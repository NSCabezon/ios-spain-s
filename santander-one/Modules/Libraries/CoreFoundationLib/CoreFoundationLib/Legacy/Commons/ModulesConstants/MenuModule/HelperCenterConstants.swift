
public struct HelpCenterConstants {
    public static let officeDate = "CITA_OFICINA"
    public static let permanentAttention = "ATENCION_PERMANENTE_CENTRO_AYUDA"
    public static let helpCenterVIP = "CENTRO_AYUDA_VIP"
}

public struct HelpCenterPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/help_center"
    
    public enum Action: String {
        case virtualAssistant = "open_virtual_assistant"
        case faq = "faq"
        case otherConsultations = "otras_consultas"
        case search = "buscador"
        case call = "llamar"
        case writeMail = "escribir_mail"
        case whatsapp = "whatsapp"
        case facebook = "facebook"
        case multichannelSign = "firma_multicanal"
        case pin = "consulta_pin"
        case cvv = "consulta_cvv"
        case withdrawMoney = "sacar_dinero_con_codigo"
        case sendMoney = "enviar_dinero"
        case invalidateTransfer = "anular_transferencia"
        case changeKey = "cambio_clave"
        case swipe = "swipe"
        case tip = "click_tip"
        case allTips = "see_all_tips"
    }
    public init() {}
}

public struct CancelTransferHelpCenterPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "centro_ayuda_anular_transferencia"
    
    public enum Action: String {
        case call = "llamar"
        case cancel = "cancelar"
    }
    public init() {}
}
