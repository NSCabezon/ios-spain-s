import Foundation

enum OTPPushLoginMessages {
    case registered(OTPPushDevice)
    case unregistered
}

extension OTPPushLoginMessages: LoginMessagesData {
    static var hash: String {
        return "OTPPushLoginMessages"
    }
}
