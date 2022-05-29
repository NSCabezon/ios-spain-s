//

import Foundation

public class PendingSolicitudesAssamble: BSANAssemble {
    
    private static let instance = PendingSolicitudesAssamble("obtSolictPendientesLa", "/BUZCO1_MOV_ENS/ws/BUZCO1_MOV_Def_Listener")
    
    static func getInstance() -> PendingSolicitudesAssamble {
        return instance
    }
}
