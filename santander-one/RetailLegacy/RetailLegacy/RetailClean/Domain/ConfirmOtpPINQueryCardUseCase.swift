import SANLegacyLibrary
import CoreFoundationLib

class ConfirmOtpPINQueryCardUseCase: UseCase<ConfirmOtpPINQueryCardUseCaseInput, ConfirmOtpPINQueryCardUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmOtpPINQueryCardUseCaseInput) throws -> UseCaseResponse<ConfirmOtpPINQueryCardUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let cardDTO = requestValues.card.cardDTO
        let otpValidationDTO = requestValues.otpValidation?.otpValidationDTO
        let codeOTP = requestValues.code
        
        let response = try provider.getBsanCardsManager().confirmPIN(cardDTO: cardDTO, otpValidationDTO: otpValidationDTO, otpCode: codeOTP)
        
        if response.isSuccess(), let numberCipherDTO = try response.getResponseData() {
            return UseCaseResponse.ok(ConfirmOtpPINQueryCardUseCaseOkOutput(numberCipher: NumberCipher(numberCipherDTO)))
        }
        let errorDescription = try response.getErrorMessage()
        let otpType = try getOTPResult(response)
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
    }
}

struct ConfirmOtpPINQueryCardUseCaseInput {
    let card: Card
    let otpValidation: OTPValidation?
    let code: String?
}

struct ConfirmOtpPINQueryCardUseCaseOkOutput {
    let numberCipher: NumberCipher
}
