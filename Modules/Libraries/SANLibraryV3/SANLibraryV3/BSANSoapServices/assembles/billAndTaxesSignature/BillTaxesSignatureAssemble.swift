public class BillTaxesSignatureAssemble: BSANAssemble {
    private static let ourInstance = BillTaxesSignatureAssemble("SIGBROWS", "/SIGBRO_ENS/ws/SIGBRO_Def_Listener")
    
    static func getInstance() -> BillTaxesSignatureAssemble {
        return ourInstance
    }
}
