import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmOtpChargeDischargeUseCase: UseCase<ConfirmOtpChargeDischargeUseCaseInput, ConfirmOtpChargeDischargeUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider

    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }

    override func executeUseCase(requestValues: ConfirmOtpChargeDischargeUseCaseInput) throws -> UseCaseResponse<ConfirmOtpChargeDischargeUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let cardDto = requestValues.card.cardDTO
        let type = requestValues.type
        let accountDTO = requestValues.account.accountDTO
        let prepaidCardDataDTO = requestValues.prepaidCardData.dto
        let validatePrepaidCardDTO = requestValues.validatePrepaidCard.dto
        let otpValidationDTO = requestValues.otpValidation?.otpValidationDTO
        let otpCode = requestValues.otpCode
        
        let loadPrepaidCardDataResponse = try provider.getBsanCardsManager().loadPrepaidCardData(cardDTO: requestValues.card.cardDTO)
        guard loadPrepaidCardDataResponse.isSuccess() else {
            let errorCode = try loadPrepaidCardDataResponse.getErrorCode()
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(try loadPrepaidCardDataResponse.getErrorCode(), .serviceDefault, errorCode))
        }

        switch Decimal.getAmountParserResult(value: type.getAmount()) {
        case .success(let decimalValue):
            let amount = Amount.createWith(value: decimalValue)

            switch type {
            case .charge:
                let response = try provider.getBsanCardsManager().confirmOTPLoadPrepaidCard(cardDTO: cardDto, amountDTO: amount.amountDTO, accountDTO: accountDTO, prepaidCardDataDTO: prepaidCardDataDTO, validateLoadPrepaidCardDTO: validatePrepaidCardDTO, otpValidationDTO: otpValidationDTO, otpCode: otpCode)
                if response.isSuccess() {
                    return UseCaseResponse.ok(ConfirmOtpChargeDischargeUseCaseOkOutput())
                } else {
                    let error = try response.getErrorMessage()
                    let otpType = try getOTPResult(response)
                    let errorCode = try response.getErrorCode()
                    return UseCaseResponse.error(GenericErrorOTPErrorOutput(error, otpType, errorCode))
                }
            case .discharge:
                let response = try provider.getBsanCardsManager().confirmOTPUnloadPrepaidCard(cardDTO: cardDto, amountDTO: amount.amountDTO, accountDTO: accountDTO, prepaidCardDataDTO: prepaidCardDataDTO, validateLoadPrepaidCardDTO: validatePrepaidCardDTO, otpValidationDTO: otpValidationDTO, otpCode: otpCode)
                if response.isSuccess() {
                    return UseCaseResponse.ok(ConfirmOtpChargeDischargeUseCaseOkOutput())
                } else {
                    let error = try response.getErrorMessage()
                    let otpType = try getOTPResult(response)
                    let errorCode = try response.getErrorCode()
                    return UseCaseResponse.error(GenericErrorOTPErrorOutput(error, otpType, errorCode))
                }
            }

        default:
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
    }
}

struct ConfirmOtpChargeDischargeUseCaseInput {
    let card: Card
    let type: ChargeDischargeType
    let account: Account
    let validatePrepaidCard: ValidatePrepaidCard
    let prepaidCardData: PrepaidCardData
    let otpValidation: OTPValidation?
    let otpCode: String?
}

struct ConfirmOtpChargeDischargeUseCaseOkOutput {
}
