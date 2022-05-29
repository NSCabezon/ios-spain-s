import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmMobileToUpUseCase: ConfirmUseCase<ConfirmMobileToUpUseCaseInput, ConfirmMobileToUpUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider

    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }

    override func executeUseCase(requestValues: ConfirmMobileToUpUseCaseInput) throws -> UseCaseResponse<ConfirmMobileToUpUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let signatureWithToken = requestValues.signature
        let signatureWithTokenDto = SignatureWithTokenDTO(signatureDTO: signatureWithToken.signature.dto, magicPhrase: signatureWithToken.magicPhrase)
        let response = try provider.getBsanMobileRechargeManager().validateMobileRechargeOTP(card: requestValues.card.cardDTO, signature: signatureWithTokenDto, mobile: requestValues.mobile, amount: requestValues.amount.amountDTO, mobileOperatorDTO: requestValues.mobileOperator.operatorDTO)

        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmMobileToUpUseCaseOkOutput(otpValidation: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmMobileToUpUseCaseOkOutput(otpValidation: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ConfirmMobileToUpUseCaseInput {
    let card: Card
    let signature: SignatureWithToken
    let mobile: String
    let amount: Amount
    let mobileOperator: MobileOperator
}

struct ConfirmMobileToUpUseCaseOkOutput {
    let otpValidation: OTP
}
