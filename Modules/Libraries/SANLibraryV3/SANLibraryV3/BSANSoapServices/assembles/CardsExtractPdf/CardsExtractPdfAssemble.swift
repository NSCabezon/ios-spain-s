import Foundation

public class CardsExtractPdfAssemble: BSANAssemble {
    
    private static let instance = CardsExtractPdfAssemble("ACTARSANPdfExtractoLa", "/CUENTA_ENS/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> CardsExtractPdfAssemble {
        return instance
    }
}
