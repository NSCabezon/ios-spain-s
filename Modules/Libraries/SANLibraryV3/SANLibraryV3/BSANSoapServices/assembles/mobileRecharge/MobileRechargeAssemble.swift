public class MobileRechargeAssemble: BSANAssemble {
    private static let instance = MobileRechargeAssemble("ACTARSANRecargaTelefonosLa", "/SCH_TARSAN_RECARGATELEFONOS_ENS/ws/BAMOBI_WS_Def_Listener", "TARSAN")
    private static let instancePb = MobileRechargeAssemble("ACTARSANRecargaTelefonosLa", "/SPB_MOSPCA_RECARGATELEFONOS_ENS/ws/BAMOBI_WS_Def_Listener", "TARSAN")

    
    static func getInstance(isPB: Bool) -> MobileRechargeAssemble {
        if (isPB) {
            return instancePb
        } else {
            return instance
        }
    }

}
