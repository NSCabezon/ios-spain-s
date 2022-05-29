import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmChargeDischargeUseCase: UseCase<ConfirmChargeDischargeUseCaseInput, ConfirmChargeDischargeUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider

    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }

    override func executeUseCase(requestValues: ConfirmChargeDischargeUseCaseInput) throws -> UseCaseResponse<ConfirmChargeDischargeUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let cardDto = requestValues.card.cardDTO
        let signatureDTO = requestValues.signature.dto
        let validatePrepaidCardDTO = requestValues.validatePrepaidCard.dto
        
        let loadPrepaidCardDataResponse = try provider.getBsanCardsManager().loadPrepaidCardData(cardDTO: requestValues.card.cardDTO)
        guard loadPrepaidCardDataResponse.isSuccess() else {
            let errorCode = try loadPrepaidCardDataResponse.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorCode, .otherError, errorCode))
        }

        let response = try provider.getBsanCardsManager().validateOTPPrepaidCard(cardDTO: cardDto, signatureDTO: signatureDTO, validateLoadPrepaidCardDTO: validatePrepaidCardDTO)

        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmChargeDischargeUseCaseOkOutput(otpValidation: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmChargeDischargeUseCaseOkOutput(otpValidation: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ConfirmChargeDischargeUseCaseInput {
    let card: Card
    let signature: Signature
    let validatePrepaidCard: ValidatePrepaidCard
}

struct ConfirmChargeDischargeUseCaseOkOutput {
    let otpValidation: OTP
}
