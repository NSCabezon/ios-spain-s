import Foundation

public struct BizumDetailPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum_detalle"
    public enum Action: String {
        case share = "compartir"
        case reuseContact = "reutilizar_contacto"
        case sendAgain = "reenviar"
        case acceptSendRequest = "aceptar_solicitud"
        case rejectSendRequest = "rechazar_solicitud"
        case cancelSend = "cancelar_envio_contacto_no_registrado"
        case refund = ""
    }
    public init() {}
}
