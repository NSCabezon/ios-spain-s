import SANLegacyLibrary
import CoreFoundationLib

class ConfirmWithdrawMoneyWithCodeUseCase: ConfirmUseCase<ConfirmWithdrawMoneyWithCodeUseCaseInput, ConfirmWithdrawMoneyWithCodeUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider

    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }

    override func executeUseCase(requestValues: ConfirmWithdrawMoneyWithCodeUseCaseInput) throws -> UseCaseResponse<ConfirmWithdrawMoneyWithCodeUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let manager = provider.getBsanCashWithdrawalManager()
        let cardDTO = requestValues.card.cardDTO
        let signatureWithToken = requestValues.signature
        let signatureWithTokenDTO = SignatureWithTokenDTO(signatureDTO: signatureWithToken.signature.dto, magicPhrase: signatureWithToken.magicPhrase)
        let response = try manager.validateOTP(cardDTO: cardDTO, signatureWithTokenDTO: signatureWithTokenDTO)

        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmWithdrawMoneyWithCodeUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmWithdrawMoneyWithCodeUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ConfirmWithdrawMoneyWithCodeUseCaseInput {
    let signature: SignatureWithToken
    let card: Card
}

struct ConfirmWithdrawMoneyWithCodeUseCaseOkOutput {
    let otp: OTP
}
