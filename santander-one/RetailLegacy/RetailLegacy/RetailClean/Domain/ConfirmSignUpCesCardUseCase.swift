import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmSignUpCesCardUseCase: ConfirmUseCase<ConfirmSignUpCesCardUseCaseInput, ConfirmSignUpCesCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider

    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }

    override func executeUseCase(requestValues: ConfirmSignUpCesCardUseCaseInput) throws -> UseCaseResponse<ConfirmSignUpCesCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {

        let phone = requestValues.cesCard.phoneNumber.notWhitespaces()
        let cardDTO = requestValues.card.cardDTO
        let signatureWithToken = requestValues.signatureWithToken
        let signatureWithTokenDTO = SignatureWithTokenDTO(signatureDTO: signatureWithToken.signature.dto, magicPhrase: signatureWithToken.magicPhrase)

        let response = try provider.getBsanCesManager().validateOTP(cardDTO: cardDTO, signatureWithTokenDTO: signatureWithTokenDTO, phone: phone)

        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmSignUpCesCardUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmSignUpCesCardUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ConfirmSignUpCesCardUseCaseInput {
    let cesCard: CesCard
    let card: Card
    let signatureWithToken: SignatureWithToken
}

struct ConfirmSignUpCesCardUseCaseOkOutput {
    let otp: OTP
}
