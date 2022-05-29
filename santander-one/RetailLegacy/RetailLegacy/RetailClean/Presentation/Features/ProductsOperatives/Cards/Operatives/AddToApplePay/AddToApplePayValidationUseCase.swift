import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class AddToApplePayValidationUseCase: UseCase<AddToApplePayValidationUseCaseInput, AddToApplePayValidationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: AddToApplePayValidationUseCaseInput) throws -> UseCaseResponse<AddToApplePayValidationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        guard let card = requestValues.card else {
            return .error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let response = try bsanManagersProvider.getBsanCardsManager().validateApplePay(card: card.cardDTO, signature: requestValues.signatureWithToken.signatureWithTokenDTO)
        guard response.isSuccess(), let validationDTO = try response.getResponseData() else {
            return .error(GenericErrorSignatureErrorOutput(
                try? response.getErrorMessage(),
                try getSignatureResult(response),
                try? response.getErrorCode())
            )
        }
        let otpValidation = OTPValidation(otpValidationDTO: validationDTO.otp)
        let otp: OTP
        
        let signatureType = try getSignatureResult(response)
        if case .otpUserExcepted = signatureType {
            otp = OTP.userExcepted(otpValidation)
        } else {
            otp = OTP.validation(otpValidation)
        }
        
        return .ok(AddToApplePayValidationUseCaseOkOutput(otp: otp))
    }
}

struct AddToApplePayValidationUseCaseInput {
    let card: Card?
    let signatureWithToken: SignatureWithToken
}

struct AddToApplePayValidationUseCaseOkOutput {
    let otp: OTP
}
