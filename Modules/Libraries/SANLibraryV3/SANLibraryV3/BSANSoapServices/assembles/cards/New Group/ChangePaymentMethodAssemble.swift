public class ChangePaymentMethodAssemble: BSANAssemble {
    
    private static let instance = ChangePaymentMethodAssemble("ACTARSANCambioFormaPago", "/TARSAN_WALLET_ENS_SAN/ws/BAMOBI_WS_Def_Listener", "TARSAN")
    
    static func getInstance() -> ChangePaymentMethodAssemble {
        return instance
    }
}
