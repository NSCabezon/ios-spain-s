public class PayLaterAssemble: BSANAssemble {
    private static let instance = PayLaterAssemble("ACTARSANAltaPagoLuego", "/TARSAN_WALLET_ENS_SAN/ws/BAMOBI_WS_Def_Listener", "TARSAN")
    
    static func getInstance() -> PayLaterAssemble {
        return instance
    }
}
