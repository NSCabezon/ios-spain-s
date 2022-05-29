import Foundation

public class ChangeLimitCardAssemble: BSANAssemble {
    
    private static let ourInstance = ChangeLimitCardAssemble("ACTARSANConsultaImagen", "/TARSAN_CONSULTAIMAGEN_ENS_SAN/ws/TARSAN_Def_Listener", "TARSAN")
    
    static func getInstance() -> ChangeLimitCardAssemble {
        return ourInstance
    }
}
