public class SepaPayeeDetailAssemble: BSANAssemble {
    private static let instance = SepaPayeeDetailAssemble("ACTRANSANBenefInterLa", "/TRASAN_BENEFINTER_ENS_SAN/ws/TRASAN_BENEFINTER_Def_Listener")
    
    static func getInstance() -> SepaPayeeDetailAssemble {
        return instance
    }
}
