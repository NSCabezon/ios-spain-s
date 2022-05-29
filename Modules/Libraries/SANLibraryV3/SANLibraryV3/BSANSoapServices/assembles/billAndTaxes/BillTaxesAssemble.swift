public class BillTaxesAssemble: BSANAssemble {
    private static let instance = BillTaxesAssemble("ACPARETRPagosRecibos", "/PARETR_PAGOSRECIBOS_ENS_SAN/ws/PARETR_Def_Listener")
    
    static func getInstance() -> BillTaxesAssemble {
        return instance
    }
}
