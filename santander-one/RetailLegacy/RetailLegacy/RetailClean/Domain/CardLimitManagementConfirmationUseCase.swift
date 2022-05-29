import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class CardLimitManagementConfirmationUseCase: ConfirmUseCase<CardLimitManagementConfirmationUseCaseInput, CardLimitManagementConfirmationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let bsanManagerProvider: BSANManagersProvider
    
    init(bsanManagerProvider: BSANManagersProvider) {
        self.bsanManagerProvider = bsanManagerProvider
    }
    
    override func executeUseCase(requestValues: CardLimitManagementConfirmationUseCaseInput) throws -> UseCaseResponse<CardLimitManagementConfirmationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        guard let creditLimitDailyAmount = requestValues.card.cardDataDTO?.cardSuperSpeedDTO?.limitDailyCredit else {
            return .error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let response: BSANResponse<OTPValidationDTO>
        switch requestValues.limit {
        case .debit(let shopping, let atm):
            response = try bsanManagerProvider.getBsanCardsManager().validateModifyDebitCardLimitOTP(cardDTO: requestValues.card.cardDTO, signatureWithToken: requestValues.signature.signatureWithTokenDTO, debitLimitDailyAmount: shopping.amountDTO, atmLimitDailyAmount: atm.amountDTO, creditLimitDailyAmount: creditLimitDailyAmount)
        case .credit(let atm):
            response = try bsanManagerProvider.getBsanCardsManager().validateModifyCreditCardLimitOTP(cardDTO: requestValues.card.cardDTO, signatureWithToken: requestValues.signature.signatureWithTokenDTO, atmLimitDailyAmount: atm.amountDTO, creditLimitDailyAmount: creditLimitDailyAmount)
        }
        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(CardLimitManagementConfirmationUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(CardLimitManagementConfirmationUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct CardLimitManagementConfirmationUseCaseInput {
    let card: Card
    let limit: CardLimit
    let signature: SignatureWithToken
}

struct CardLimitManagementConfirmationUseCaseOkOutput {
    let otp: OTP
}
