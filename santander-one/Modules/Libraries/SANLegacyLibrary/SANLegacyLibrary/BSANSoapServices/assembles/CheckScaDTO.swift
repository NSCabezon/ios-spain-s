import Foundation

public enum ScaLoginState: String, Codable {
    case notApply = "0"
    case temporaryLock = "1"
    case requestOtp = "2"
    case notPhone = "3"
    case requestOtpFirstTime = "4"
}

public enum ScaAccountState: String, Codable {
    case notApply = "0"
    case temporaryLock = "1"
    case requestOtp = "2"
    case notPhone = "3"
}

public struct CheckScaDTO: Codable  {
    public var loginIndicator: ScaLoginState?
    public var accountIndicator: ScaAccountState?
    public let penalizeDate: Date?
    public let systemDate: Date?
    
    public init(loginIndicator: ScaLoginState?, accountIndicator: ScaAccountState?, penalizeDate: Date?, systemDate: Date?) {
        self.loginIndicator = loginIndicator
        self.accountIndicator = accountIndicator
        self.penalizeDate = penalizeDate
        self.systemDate = systemDate
    }
}
