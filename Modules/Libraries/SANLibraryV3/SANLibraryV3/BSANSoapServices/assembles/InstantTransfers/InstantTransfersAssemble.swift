import Foundation

public class InstantTransfersAssemble: BSANAssemble {
    
    private static let instance = InstantTransfersAssemble("ACTRASANINT", "/TRASAN_INMEDIATAS_ENS_SAN/ws/TRASAN_Def_Listener")
    
    static func getInstance() -> InstantTransfersAssemble {
        return instance
    }
}
