import CoreFoundationLib
import SANLegacyLibrary

class ValidateOTPCreateNoSepaUsualTransferUseCase: UseCase<ValidateOTPCreateNoSepaUsualTransferUseCaseInput, ValidateOTPCreateNoSepaUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateOTPCreateNoSepaUsualTransferUseCaseInput) throws -> UseCaseResponse<ValidateOTPCreateNoSepaUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let signatureWithTokenDTO = requestValues.signatureWithToken.signatureWithTokenDTO
        
        let response = try provider.getBsanTransfersManager().validateCreateNoSepaPayeeOTP(signatureWithTokenDTO: signatureWithTokenDTO)
        
        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ValidateOTPCreateNoSepaUsualTransferUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ValidateOTPCreateNoSepaUsualTransferUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ValidateOTPCreateNoSepaUsualTransferUseCaseInput {
    let signatureWithToken: SignatureWithToken
}

struct ValidateOTPCreateNoSepaUsualTransferUseCaseOkOutput {
    let otp: OTP
}
