public class SignatureAssemble: BSANAssemble {
    private static let instance = SignatureAssemble("ACADFIELGestionFirma", "/ADFIEL_GFC_ENS_SAN/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> SignatureAssemble {
        return instance
    }
}
