import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateOTPUpdateNoSepaUsualTransferUseCase: UseCase<ValidateOTPUpdateNoSepaUsualTransferUseCaseInput, ValidateOTPUpdateNoSepaUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateOTPUpdateNoSepaUsualTransferUseCaseInput) throws -> UseCaseResponse<ValidateOTPUpdateNoSepaUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let signatureWithTokenDTO = requestValues.signatureWithToken.signatureWithTokenDTO
        let response = try provider.getBsanTransfersManager().validateUpdateNoSepaPayeeOTP(signatureWithTokenDTO: signatureWithTokenDTO)
        
        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ValidateOTPUpdateNoSepaUsualTransferUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ValidateOTPUpdateNoSepaUsualTransferUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ValidateOTPUpdateNoSepaUsualTransferUseCaseInput {
    let signatureWithToken: SignatureWithToken
}

struct ValidateOTPUpdateNoSepaUsualTransferUseCaseOkOutput {
    let otp: OTP
}
