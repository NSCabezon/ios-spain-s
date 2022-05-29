import Foundation

public class LoanOperationsAssemble: BSANAssemble {
    
    private static let instance = LoanOperationsAssemble("ACPREST1OPERATIVAPREST", "/PREST1_OPERATIVAPREST_ENS_SAN/ws/PREST1_OPERATIVAPREST_Def_Listener", "PREST1")
    
    static func getInstance() -> LoanOperationsAssemble {
        return instance
    }
    
}
