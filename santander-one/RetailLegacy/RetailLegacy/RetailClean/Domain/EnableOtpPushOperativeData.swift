import Foundation

struct EnableOtpPushOperativeData: OperativeParameter {
    let isAnyDeviceRegistered: Bool?
    var alias: String?
    var registrationDate: Date?
    var operativeMode: EnableOTPPushOperativeMode?
    var tokenPush: Data?
    var deviceModel: String?
    var closeReason: EnableOtpPushOperativeCloseReason?
    
    init(isAnyDeviceRegistered: Bool?) {
        self.isAnyDeviceRegistered = isAnyDeviceRegistered
    }
}
