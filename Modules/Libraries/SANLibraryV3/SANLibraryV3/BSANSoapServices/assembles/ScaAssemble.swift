class ScaAssemble: BSANAssemble {
    private static let instance = ScaAssemble("ACSUPPFPServiciosSCAM", "/SUPPFP_SCA_ENS_MOV/ws/SUPPFP_Def_Listener")
    
    static func getInstance() -> ScaAssemble {
        return instance
    }
}
