
import Foundation

public class DepositsAssemble: BSANAssemble {

    private static let instance = DepositsAssemble("ACBAMOBIDEP", "/SCH_BAMOBI_DEPOSITOS_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> DepositsAssemble {
        return instance
    }
	
}
