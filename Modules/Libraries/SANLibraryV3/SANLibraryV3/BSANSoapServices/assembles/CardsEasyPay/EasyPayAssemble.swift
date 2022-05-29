public class EasyPayAssemble: BSANAssemble {
    private static let ourInstance = EasyPayAssemble("ACTARSANPFacilMov", "/TARSAN_PAGOFACIL_ENS_SCH/ws/BAMOBI_WS_Def_Listener", "TARSAN")
    
    static func getInstance() -> EasyPayAssemble {
        return ourInstance
    }
}
