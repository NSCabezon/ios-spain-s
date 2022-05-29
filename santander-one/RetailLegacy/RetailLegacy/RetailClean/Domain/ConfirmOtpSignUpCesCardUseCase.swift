import SANLegacyLibrary
import CoreFoundationLib

class ConfirmOtpSignUpCesCardUseCase: UseCase<ConfirmOtpSignUpCesCardUseCaseInput, ConfirmOtpSignUpCesCardUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmOtpSignUpCesCardUseCaseInput) throws -> UseCaseResponse<ConfirmOtpSignUpCesCardUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let cardDTO = requestValues.card.cardDTO
        let otpValidationDTO = requestValues.otpValidation?.otpValidationDTO
        let codeOTP = requestValues.code
        
        let response = try provider.getBsanCesManager().confirmOTP(cardDTO: cardDTO, otpValidationDTO: otpValidationDTO, otpCode: codeOTP)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
        return UseCaseResponse.ok(ConfirmOtpSignUpCesCardUseCaseOkOutput())
    }
}

struct ConfirmOtpSignUpCesCardUseCaseInput {
    let card: Card
    let otpValidation: OTPValidation?
    let code: String?
}

struct ConfirmOtpSignUpCesCardUseCaseOkOutput {
}
