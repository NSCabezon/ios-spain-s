//

import Foundation

public struct OTPPushConfirmRegisterDeviceInputDTO {
    public let deviceUDID: String
    public let deviceToken: String
    public let deviceAlias: String
    public let deviceLanguage: String
    public let deviceCode: String
    public let deviceModel: String
    public let deviceBrand: String
    public let appVersion: String
    public let sdkVersion: String
    public let soVersion: String
    public let platform: String
    public let modUser: String
    public let operativeDes: String
    
    /// Initialize a RegisterDevice entity with all data needed by the WS.
    ///
    /// - Parameters:
    ///   - deviceUDID: The UDID of Twinpush
    ///   - deviceToken: The APNS deviceToken
    ///   - deviceAlias: The alias of the device (default: "")
    ///   - deviceLanguage: The device language
    ///   - deviceCode: The device code (i.e. iPhone 9,3)
    ///   - deviceModel: The device model (i.e. iPhone)
    ///   - deviceBrand: The device brand (default: "Apple")
    ///   - appVersion: The app version (i.e. 4.2.10)
    ///   - sdkVersion: The Twinpush SDK version
    ///   - soVersion: The iOS version
    ///   - platform: The platform (default: "ios")
    ///   - modUser: Unknown user info (default: "MI")
    ///   - operativeDes: Unknown data (default: "GENERAL")
    public init(deviceUDID: String, deviceToken: String, deviceAlias: String, deviceLanguage: String, deviceCode: String, deviceModel: String, deviceBrand: String = "Apple", appVersion: String, sdkVersion: String, soVersion: String, platform: String = "ios", modUser: String = "MI", operativeDes: String = "GENERAL") {
        self.deviceUDID = deviceUDID
        self.deviceToken = deviceToken
        self.deviceAlias = deviceAlias
        self.deviceLanguage = deviceLanguage
        self.deviceCode = deviceCode
        self.deviceModel = deviceModel
        self.deviceBrand = deviceBrand
        self.appVersion = appVersion
        self.sdkVersion = sdkVersion
        self.soVersion = soVersion
        self.platform = platform
        self.modUser = modUser
        self.operativeDes = operativeDes
    }
}
