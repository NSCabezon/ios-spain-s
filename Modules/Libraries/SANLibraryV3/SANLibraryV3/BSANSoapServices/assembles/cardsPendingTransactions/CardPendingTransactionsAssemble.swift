public class CardPendingTransactionsAssemble: BSANAssemble {
    private static let ourInstance = CardPendingTransactionsAssemble("ACTARSANPdteLiquidar", "/TARSAN_WALLET_ENS_SAN/ws/BAMOBI_WS_Def_Listener", "TARSAN")
    
    static func getInstance() -> CardPendingTransactionsAssemble {
        return ourInstance
    }
}
