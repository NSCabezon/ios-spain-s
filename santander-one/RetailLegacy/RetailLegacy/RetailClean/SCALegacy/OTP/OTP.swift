//

enum OTP: OperativeParameter {
    case userExcepted(OTPValidation)
    case validation(OTPValidation)
}
