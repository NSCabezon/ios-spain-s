import CoreFoundationLib
import SANLegacyLibrary

class ValidateOTPUpdateUsualTransferUseCase: UseCase<ValidateOTPUpdateUsualTransferUseCaseInput, ValidateOTPUpdateUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateOTPUpdateUsualTransferUseCaseInput) throws -> UseCaseResponse<ValidateOTPUpdateUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let signatureWithTokenDTO = requestValues.signatureWithToken.signatureWithTokenDTO
        
        let response = try provider.getBsanTransfersManager().validateUpdateSepaPayeeOTP(signatureWithTokenDTO: signatureWithTokenDTO)
        
        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ValidateOTPUpdateUsualTransferUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ValidateOTPUpdateUsualTransferUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ValidateOTPUpdateUsualTransferUseCaseInput {
    let signatureWithToken: SignatureWithToken
}

struct ValidateOTPUpdateUsualTransferUseCaseOkOutput {
    let otp: OTP
}
