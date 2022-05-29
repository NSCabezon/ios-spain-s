import SANLegacyLibrary
import CoreFoundationLib

class ConfirmOtpCVVQueryCardUseCase: UseCase<ConfirmOtpCVVQueryCardUseCaseInput, ConfirmOtpCVVQueryCardUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmOtpCVVQueryCardUseCaseInput) throws -> UseCaseResponse<ConfirmOtpCVVQueryCardUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let cardDTO = requestValues.card.cardDTO
        let otpValidationDTO = requestValues.otpValidation?.otpValidationDTO
        let codeOTP = requestValues.code
        
        let response = try provider.getBsanCardsManager().confirmCVV(cardDTO: cardDTO, otpValidationDTO: otpValidationDTO, otpCode: codeOTP)
        
        if response.isSuccess(), let numberCipherDto = try response.getResponseData() {
            return UseCaseResponse.ok(ConfirmOtpCVVQueryCardUseCaseOkOutput(numberCipher: NumberCipher(numberCipherDto)))
        }
        let errorDescription = try response.getErrorMessage()
        let otpType = try getOTPResult(response)
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
    }
}

struct ConfirmOtpCVVQueryCardUseCaseInput {
    let card: Card
    let otpValidation: OTPValidation?
    let code: String?
}

struct ConfirmOtpCVVQueryCardUseCaseOkOutput {
    let numberCipher: NumberCipher
}
