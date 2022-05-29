import Foundation

public enum ReturnCodeOTPPush: Int, Codable {
    case rightRegisteredDevice = 0
    case anotherRegisteredDevice
    case notRegisteredDevice
    
    public init?(_ type: Int) {
        self.init(rawValue: type)
    }
}

public struct OTPPushValidateDeviceDTO: Codable {
    public var returnCode: ReturnCodeOTPPush?
    
    public init() {}
}
