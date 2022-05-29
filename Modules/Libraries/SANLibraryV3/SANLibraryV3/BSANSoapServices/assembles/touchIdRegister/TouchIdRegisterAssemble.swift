public class TouchIdRegisterAssemble: BSANAssemble {
    private static let instance = TouchIdRegisterAssemble("ACACSIC1AccesoSinClave", "/ACSIC1_ACCESOSINCLAVE_ENS_SAN/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> TouchIdRegisterAssemble {
        return instance
    }
}
