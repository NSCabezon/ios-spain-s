public class CardsPayOffAssemble: BSANAssemble {
    private static let instance = CardsPayOffAssemble("ACTARSANIngresoTarjeta", "/TARSAN_WALLET_ENS_SAN/ws/BAMOBI_WS_Def_Listener", "TARSAN")
    
    static func getInstance() -> CardsPayOffAssemble {
        return instance
    }
}
