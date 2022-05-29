import CoreDomain

public enum FingerPrintFlag {
    case biometry
    case signature
}

public struct SanKeyOTPValidationDTO {
    public let tokenSteps: String?
    public let fingerPrintFlag: FingerPrintFlag
    public let otpValidationDTO: OTPValidationDTO?

    public init(tokenSteps: String? = nil,
                fingerPrintFlag: FingerPrintFlag = .signature,
                otpValidationDTO: OTPValidationDTO? = nil) {
        self.tokenSteps = tokenSteps
        self.fingerPrintFlag = fingerPrintFlag
        self.otpValidationDTO = otpValidationDTO
    }
}
