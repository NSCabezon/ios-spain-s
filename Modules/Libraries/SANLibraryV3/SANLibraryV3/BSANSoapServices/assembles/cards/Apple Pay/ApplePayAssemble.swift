import Foundation

class ApplePayAssemble: BSANAssemble {
    
    private static let instance = ApplePayAssemble("ACINAPPRAppelPay", "/INAPPR_APPELPAY_SAN_ENS/ws/INAPPR_Def_Listener", "INAPPR")
    
    static func getInstance() -> ApplePayAssemble {
        return instance
    }
}
