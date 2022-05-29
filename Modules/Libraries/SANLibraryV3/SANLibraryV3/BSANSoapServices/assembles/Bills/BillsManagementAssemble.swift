public class BillsManagementAssemble: BSANAssemble {
    
    private static let instance = BillsManagementAssemble("ACRECSANCambioMasivo", "/RECSAN_CAMBIOMASIVO_ENS_SAN/ws/BAMOBI_WS_Def_Listener", "RECSAN")
    
    static func getInstance() -> BillsManagementAssemble {
        return instance
    }
}
