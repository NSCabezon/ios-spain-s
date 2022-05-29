import Foundation

public class EmittedTransferAssamble: BSANAssemble {
    
    private static let instance = EmittedTransferAssamble("ACTRASANConsultasTransfLa", "/TRASAN_CONSULTAS_TRANSF_ENS/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> EmittedTransferAssamble {
        return instance
    }
}
