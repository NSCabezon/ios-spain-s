import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class CardLimitManagementOTPConfirmationUseCase: UseCase<CardLimitManagementOTPConfirmationUseCaseInput, Void, GenericErrorOTPErrorOutput> {
    
    private let bsanManagerProvider: BSANManagersProvider
    
    init(bsanManagerProvider: BSANManagersProvider) {
        self.bsanManagerProvider = bsanManagerProvider
    }
    
    override func executeUseCase(requestValues: CardLimitManagementOTPConfirmationUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        guard let superSpeedCard = requestValues.card.cardDataDTO?.cardSuperSpeedDTO else { return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil)) }
        let response: BSANResponse<Void>
        switch requestValues.limit {
        case .debit(let shopping, let atm):
            response = try bsanManagerProvider.getBsanCardsManager().confirmModifyDebitCardLimitOTP(cardDTO: requestValues.card.cardDTO, otpCode: requestValues.otpCode, otpValidationDTO: requestValues.otp.otpValidationDTO, debitLimitDailyAmount: shopping.amountDTO, atmLimitDailyAmount: atm.amountDTO, cardSuperSpeedDTO: superSpeedCard)
        case .credit(let atm):
            response = try bsanManagerProvider.getBsanCardsManager().confirmModifyCreditCardLimitOTP(cardDTO: requestValues.card.cardDTO, otpCode: requestValues.otpCode, otpValidationDTO: requestValues.otp.otpValidationDTO, atmLimitDailyAmount: atm.amountDTO, cardSuperSpeedDTO: superSpeedCard)
        }
        guard response.isSuccess() else {
            let error = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(error, otpType, errorCode))
        }
        return .ok()
    }
}

struct CardLimitManagementOTPConfirmationUseCaseInput {
    let limit: CardLimit
    let otp: OTPValidation
    let otpCode: String
    let card: Card
}
