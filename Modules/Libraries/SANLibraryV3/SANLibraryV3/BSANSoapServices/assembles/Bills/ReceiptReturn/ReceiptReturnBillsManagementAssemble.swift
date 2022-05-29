public class ReceiptReturnBillsManagementAssemble: BSANAssemble {
    private static let instance = ReceiptReturnBillsManagementAssemble("RECSANDR", "/SCH_RECSAN_RECIBOS_ENS/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> ReceiptReturnBillsManagementAssemble {
        return instance
    }
}
