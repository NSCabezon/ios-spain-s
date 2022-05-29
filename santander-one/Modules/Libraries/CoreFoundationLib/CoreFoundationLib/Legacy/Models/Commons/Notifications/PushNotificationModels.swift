import Foundation

public enum PushNotificationMaxTime {
    public static let ecommerce: Int = 7
    public static let otpPush: Int = 5
}

public struct TwinpushPersistedNotification: Codable, Equatable {
    public let code: String
    public let sentDate: Date
    
    public init(code: String, sentDate: Date) {
        self.code = code
        self.sentDate = sentDate
    }
}

public enum ReturnCodeOTPPush: Int {
    case rightRegisteredDevice = 0
    case anotherRegisteredDevice = 1
    case notRegisteredDevice = 2
    
    public init?(_ type: Int) {
        self.init(rawValue: type)
    }
}
