import Foundation

public struct ConfirmScaDTO: Codable  {
    public let otpOkIndicator: String?
    public let penalizeScaIndicator: String?
    public let otpValIndicator: String?
    
    public init(otpOkIndicator: String?, penalizeScaIndicator: String?, otpValIndicator: String?) {
        self.otpOkIndicator = otpOkIndicator
        self.penalizeScaIndicator = penalizeScaIndicator
        self.otpValIndicator = otpValIndicator
    }
}
