import SANLegacyLibrary

public class BizumValidateMoneyTransferOTPEntity {
    public let dto: BizumValidateMoneyTransferOTPDTO
    
    public init(_ dto: BizumValidateMoneyTransferOTPDTO) {
        self.dto = dto
    }
    
    public var otpExcepted: Bool {
        self.dto.otp.otpExcepted
    }
    
    public var otp: OTPValidationEntity {
        OTPValidationEntity(self.dto.otp)
    }
}
