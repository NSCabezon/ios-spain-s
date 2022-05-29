import Foundation

public class ChangeCardAliasAssemble: BSANAssemble {
    
    private static let instance = ChangeCardAliasAssemble("ACTARSANAliasTarjeta", "/TARSAN_WALLET_ENS_SAN/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> ChangeCardAliasAssemble {
        return instance
    }
    
}
