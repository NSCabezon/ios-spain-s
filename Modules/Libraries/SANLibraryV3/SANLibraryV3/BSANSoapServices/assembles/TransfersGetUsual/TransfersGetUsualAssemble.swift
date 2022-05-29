import Foundation

public class TransfersGetUsualAssemble: BSANAssemble {
    
    private static let instance = TransfersGetUsualAssemble("ACTRANSANBenefInterLa", "/TRASAN_BENEFINTER_ENS_SAN/ws/TRASAN_BENEFINTER_Def_Listener")
    
    static func getInstance() -> TransfersGetUsualAssemble {
        return instance
    }
}
