class OTPPushAssemble: BSANAssemble {
    
    private static let instance = OTPPushAssemble("ACSUPOTEAltaOTE", "/SUPOTE_AltaOTE_ENS_MOV/ws/SUPOTE_AltaOTE_Def_Listener", "SUPOTE")
    
    static func getInstance() -> OTPPushAssemble {
        return instance
    }
}
