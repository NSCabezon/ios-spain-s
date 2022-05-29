//

import Foundation

public class AccountEasyPayAssemble: BSANAssemble {
    
    static func getInstance() -> AccountEasyPayAssemble {
        return AccountEasyPayAssemble("ACOFECOMEAPAY", "/OFECOM_EASYPAY_ENS_SAN/ws/BAMOBI_WS_Def_Listener")
    }
}
