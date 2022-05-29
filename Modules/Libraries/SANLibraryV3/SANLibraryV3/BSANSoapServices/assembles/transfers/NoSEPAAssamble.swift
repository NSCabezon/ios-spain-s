import Foundation

public class NoSEPAAssemble: BSANAssemble {
    
    private static let instance = NoSEPAAssemble("ACTRASANEmisionInter", "/TRASAN_EMISIONINTER_ENS_SAN/ws/TRASAN_Def_Listener")
    
    static func getInstance() -> NoSEPAAssemble {
        return instance
    }
}




