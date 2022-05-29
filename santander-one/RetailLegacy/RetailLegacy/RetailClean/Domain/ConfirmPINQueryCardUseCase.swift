import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmPINQueryCardUseCase: ConfirmUseCase<ConfirmPINQueryCardUseCaseInput, ConfirmPINQueryCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider

    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }

    override func executeUseCase(requestValues: ConfirmPINQueryCardUseCaseInput) throws -> UseCaseResponse<ConfirmPINQueryCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {

        let cardDTO = requestValues.card.cardDTO
        let signatureWithToken = requestValues.signatureWithToken
        let signatureWithTokenDTO = SignatureWithTokenDTO(signatureDTO: signatureWithToken.signature.dto, magicPhrase: signatureWithToken.magicPhrase)

        let response = try provider.getBsanCardsManager().validatePINOTP(cardDTO: cardDTO, signatureWithTokenDTO: signatureWithTokenDTO)

        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmPINQueryCardUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmPINQueryCardUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ConfirmPINQueryCardUseCaseInput {
    let card: Card
    let signatureWithToken: SignatureWithToken
}

struct ConfirmPINQueryCardUseCaseOkOutput {
    let otp: OTP
}
