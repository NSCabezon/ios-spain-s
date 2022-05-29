public class PINAssemble: BSANAssemble {
    private static let instance = PINAssemble("ACTARSANConsultaDePIN", "/TARSAN_WALLET_ENS_SAN/ws/BAMOBI_WS_Def_Listener", "TARSAN")

    static func getInstance() -> PINAssemble {
        return instance
    }
}
