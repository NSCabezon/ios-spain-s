import Foundation
public class FundSubscriptionAssemble: BSANAssemble {
    
    private static let instance = FundSubscriptionAssemble("ACFONDO1SuscripFondos", "/FONDO1_FONDOS_ENS_SAN/ws/FONDO1_Def_Listener")
    
    static func getInstance() -> FundSubscriptionAssemble {
        return instance
    }
    
}
