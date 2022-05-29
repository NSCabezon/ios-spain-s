import Foundation

public class ChangeProductAliasAssemble: BSANAssemble {
    
    private static let instance = ChangeProductAliasAssemble("ACNUEBROPosGlo", "/TARSAN_WALLETECASH_ENS_SAN/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> ChangeProductAliasAssemble {
        return instance
    }
}
