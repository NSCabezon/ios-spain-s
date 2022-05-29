import Foundation

public class ScheduledTransfersAssamble: BSANAssemble {
    
    private static let instance = ScheduledTransfersAssamble("ACTRASANPeriodicasLa", "/TRASAN_PERIODICAS_ENS_SAN/ws/BAMOBI_WS_Def_Listener", "TRASAN")
    
    static func getInstance() -> ScheduledTransfersAssamble {
        return instance
    }
}
