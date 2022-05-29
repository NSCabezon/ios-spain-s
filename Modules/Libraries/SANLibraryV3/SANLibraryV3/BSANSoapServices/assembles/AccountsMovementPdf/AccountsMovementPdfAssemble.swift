import Foundation

public class AccountsMovementPdfAssemble: BSANAssemble {
    
    private static let instance = AccountsMovementPdfAssemble("ACCUENTAPdfMovimientoLa", "/CUENTA_ENS/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> AccountsMovementPdfAssemble {
        return instance
    }
}
