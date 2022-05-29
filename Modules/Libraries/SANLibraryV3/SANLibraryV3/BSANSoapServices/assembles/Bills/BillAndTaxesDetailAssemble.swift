public class BillAndTaxesDetailAssemble: BSANAssemble {
    private static let instance = BillAndTaxesDetailAssemble("RECSANCR", "/SCH_RECSAN_RECIBOS_ENS/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> BillAndTaxesDetailAssemble {
        return instance
    }
}
