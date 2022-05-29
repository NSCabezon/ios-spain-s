import Foundation
import CoreFoundationLib

struct TransfersHomeSendMoneyPage: PageWithActionTrackable, EmmaTrackable {
    var emmaToken: String
    
    typealias ActionType = Action
    let page = "pos_global_envio_dinero"
    enum Action: String {
        case bizum
    }
    init() {
        self.emmaToken = ""
    }
    init(emmaToken: String) {
        self.emmaToken = emmaToken
    }
}
