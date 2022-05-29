import CoreFoundationLib
import SANLegacyLibrary

class ValidateOTPCreateUsualTransferUseCase: UseCase<ValidateOTPCreateUsualTransferUseCaseInput, ValidateOTPCreateUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateOTPCreateUsualTransferUseCaseInput) throws -> UseCaseResponse<ValidateOTPCreateUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let signatureWithTokenDTO = requestValues.signatureWithToken.signatureWithTokenDTO
        
        let response = try provider.getBsanTransfersManager().validateCreateSepaPayeeOTP(signatureWithTokenDTO: signatureWithTokenDTO)
        
        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ValidateOTPCreateUsualTransferUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ValidateOTPCreateUsualTransferUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ValidateOTPCreateUsualTransferUseCaseInput {
    let signatureWithToken: SignatureWithToken
}

struct ValidateOTPCreateUsualTransferUseCaseOkOutput {
    let otp: OTP
}
