public class MifidAssemble: BSANAssemble {
    private static let instance = MifidAssemble("ACVALOREValoresMifid", "/VALORE_MIFIDLA_ENS/ws/VALORE_Def_Listener")
    
    static func getInstance() -> MifidAssemble {
        return instance
    }
}
