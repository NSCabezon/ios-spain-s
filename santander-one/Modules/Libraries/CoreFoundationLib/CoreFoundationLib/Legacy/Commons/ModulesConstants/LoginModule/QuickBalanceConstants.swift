
public struct QuickBalancePullOffers {
    public static let quickBalanceTutorialVideo = "QUICK_BALANCE_TUTORIAL_VIDEO"
}
// MARK: - Tracker
public struct QuickBalancePage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "saldo_rapido"
    
    public enum Action: String {
        case enable = "activar"
        case manualReload = "recargar_manual"
        case okManual = "ok_manual"
        case errorManual = "error_manual"
        case autoReload = "recargar_auto"
        case okAuto = "ok_auto"
        case errorAuto = "error_auto"
        case notActivated = "no_activado"
        case deeplink = "deeplink"
        case video = "ver_video"
        case bizum = "bizum"
        case sendMoney = "enviar_dinero"
        case pin = "consultar_pin"
        case cardOff = "apagar_tarjeta"
        case security = "seguridad"
    }
    public init() {}
}
