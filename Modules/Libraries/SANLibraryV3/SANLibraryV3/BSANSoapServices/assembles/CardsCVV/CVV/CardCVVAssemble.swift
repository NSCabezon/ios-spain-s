public class CardCVVAssemble: BSANAssemble {
    private static let ourInstance = CardCVVAssemble("ACTARSANConsultaDeCVV", "/TARSAN_CONSULTACVV2_ENS_SAN/ws/BAMOBI_WS_Def_Listener")
    
    static func getInstance() -> CardCVVAssemble {
        return ourInstance
    }
}
