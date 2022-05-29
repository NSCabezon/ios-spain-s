public class PensionOperationsAssemble: BSANAssemble {
    private static let instance = PensionOperationsAssemble("ACPLANE1AportacionPlan", "/PLANE1_APORTACION_ENS_SAN/ws/PLANE1_AportacionPlan_Def_Listener", "PLANE1")
    
    static func getInstance() -> PensionOperationsAssemble {
        return instance
    }
}
