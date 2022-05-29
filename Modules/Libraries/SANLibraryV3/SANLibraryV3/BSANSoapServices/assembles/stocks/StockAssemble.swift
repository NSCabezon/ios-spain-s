import Foundation

public class StockAssemble: BSANAssemble {
    
    private static let instance = StockAssemble("ACBAMOBIVAL", "/SCH_BAMOBI_VALORES_ENS/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> StockAssemble {
        return instance
    }
    
}
