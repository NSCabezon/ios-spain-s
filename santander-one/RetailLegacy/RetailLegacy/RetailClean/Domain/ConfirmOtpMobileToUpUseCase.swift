import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmOtpMobileToUpUseCase: UseCase<ConfirmOtpMobileToUpUseCaseInput, ConfirmOtpMobileToUpUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmOtpMobileToUpUseCaseInput) throws -> UseCaseResponse<ConfirmOtpMobileToUpUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let otpValidationDTO = requestValues.otpValidation?.otpValidationDTO
        let response = try provider.getBsanMobileRechargeManager().confirmMobileRecharge(card: requestValues.card.cardDTO, otpValidationDTO: otpValidationDTO, otpCode: requestValues.otpCode)
        guard response.isSuccess() else {
            let error = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(error, otpType, errorCode))
        }
        
        return UseCaseResponse.ok(ConfirmOtpMobileToUpUseCaseOkOutput())
    }
}

struct ConfirmOtpMobileToUpUseCaseInput {
    let card: Card
    let otpValidation: OTPValidation?
    let otpCode: String?
}

struct ConfirmOtpMobileToUpUseCaseOkOutput {
}
