public class OnePlanAssemble: BSANAssemble {
    private static let instance = OnePlanAssemble("WSTENENCIAPLANES", "/OFECOM_EASYPAY_ENS_SAN/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> OnePlanAssemble {
        return instance
    }
}
