public class FundTransferAssemble: BSANAssemble {
    private static let instance = FundTransferAssemble("ACFONDO1TraspasoFondos", "/FONDO1_FONDOS_ENS_SAN/ws/FONDO1_Def_Listener")
    
    static func getInstance() -> FundTransferAssemble {
        return instance
    }
}
