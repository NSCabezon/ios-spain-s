import CoreFoundationLib
import SANLegacyLibrary

class ConfirmEnableOtpPushUseCase: UseCase<ConfirmEnableOtpPushUseCaseInput, ConfirmEnableOtpPushUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmEnableOtpPushUseCaseInput) throws -> UseCaseResponse<ConfirmEnableOtpPushUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let response = try provider.getBsanOTPPushManager().validateRegisterDevice(signature: requestValues.signature.signatureWithTokenDTO)
        
        let signatureType = try getSignatureResult(response)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
        
        let otpValidation = OTPValidation(otpValidationDTO: data)
        let otp: OTP
        
        if case .otpUserExcepted = signatureType {
            otp = OTP.userExcepted(otpValidation)
        } else {
            otp = OTP.validation(otpValidation)
        }
        
        return UseCaseResponse.ok(ConfirmEnableOtpPushUseCaseOkOutput(otp: otp))
    }
}

struct ConfirmEnableOtpPushUseCaseInput {
    let signature: SignatureWithToken
}

struct ConfirmEnableOtpPushUseCaseOkOutput {
    let otp: OTP
}
