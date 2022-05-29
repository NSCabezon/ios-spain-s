public class TouchIdLoginAssemble: BSANAssemble {
    private static let instance = TouchIdLoginAssemble("ACACSIC1AccesoSinClave", "/ACSIC1_ACCESOSINSEG_ENS_SAN/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> TouchIdLoginAssemble {
        return instance
    }
}
