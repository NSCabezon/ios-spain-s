public struct TrackerPageWidget {
    public static let page = "widget"
    
    public enum Action: String {
        case manualRechare = "recargar_manual"
        case manualOk = "ok_manual"
        case manualError = "error_manual"
        case autoRecharge = "recargar_auto"
        case autoOK = "ok_auto"
        case autoError = "error_auto"
        case noActivated = "no_activado"
        case deeplink
    }
}
