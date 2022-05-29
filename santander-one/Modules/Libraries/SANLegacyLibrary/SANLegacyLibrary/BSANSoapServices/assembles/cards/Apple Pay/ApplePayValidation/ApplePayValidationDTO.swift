import Foundation

public struct ApplePayValidationDTO: Codable  {
    public let otp: OTPValidationDTO
    
    public init(otp: OTPValidationDTO) {
        self.otp = otp
    }
}
