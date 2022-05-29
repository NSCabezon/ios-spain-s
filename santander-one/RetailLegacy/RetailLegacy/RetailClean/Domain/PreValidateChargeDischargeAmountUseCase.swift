import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class PreValidateChargeDischargeAmountUseCase: UseCase<PreValidateChargeDischargeAmountUseCaseInput, PreValidateChargeDischargeAmountUseCaseOkOutput, PreValidateChargeDischargeAmountUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: PreValidateChargeDischargeAmountUseCaseInput) throws -> UseCaseResponse<PreValidateChargeDischargeAmountUseCaseOkOutput, PreValidateChargeDischargeAmountUseCaseErrorOutput> {
        let loadPrepaidCardDataResponse = try provider.getBsanCardsManager().loadPrepaidCardData(cardDTO: requestValues.card.cardDTO)
        guard loadPrepaidCardDataResponse.isSuccess() else {
            return UseCaseResponse.error(PreValidateChargeDischargeAmountUseCaseErrorOutput(errorTitle: "generic_alert_title_errorData", errorSubtitle: try loadPrepaidCardDataResponse.getErrorCode()))
        }
        switch requestValues.type {
        case .charge(let value):
            switch Decimal.getAmountParserResult(value: value) {
            case .success(let decimalValue):

                let eCash = CardFactory.isEcashMini(cardDTO: requestValues.card.cardDTO)
                let minimumAmountInt = (eCash)
                    ? ChargeDischargeCardOperative.Constants.minimumChargeAmountECashMini
                    : ChargeDischargeCardOperative.Constants.minimumChargeAmountOtherPrepaidCards
                let maxAmountInt = (eCash)
                    ? ChargeDischargeCardOperative.Constants.maximumChargeAmountECashMini
                    : ChargeDischargeCardOperative.Constants.maximumChargeAmountOtherPrepaidCards

                let inputAmount = Amount.createWith(value: decimalValue)
                if let inputValue = inputAmount.value {
                    let minimumDecimal = Decimal(minimumAmountInt.rawValue)
                    let maximumDecimal = Decimal(maxAmountInt.rawValue)
                    if inputValue < minimumDecimal || inputValue > maximumDecimal {
                        return UseCaseResponse.error(PreValidateChargeDischargeAmountUseCaseErrorOutput(errorTitle: "generic_alert_title_errorData", errorSubtitle: "chargeDischarge_alert_betweenValue", minAmount: minimumAmountInt.rawValue, maxAmount: maxAmountInt.rawValue))
                    }
                }
                return UseCaseResponse.ok(PreValidateChargeDischargeAmountUseCaseOkOutput())
            case .error(let error):
                if let genericError = getGenericError(error: error) {
                    return UseCaseResponse.error(PreValidateChargeDischargeAmountUseCaseErrorOutput(errorTitle: "generic_alert_title_errorData", errorSubtitle: genericError))
                }
            }
        case .discharge(let value):
            switch Decimal.getAmountParserResult(value: value) {
            case .success(let decimalValue):
                let inputAmount = Amount.createWith(value: decimalValue)
                let cardAmount = requestValues.card.getAmount()
                if let inputValue = inputAmount.value, let cardValue = cardAmount?.value {
                    if inputValue > cardValue {
                        return UseCaseResponse.error(PreValidateChargeDischargeAmountUseCaseErrorOutput(errorTitle: "generic_alert_title_errorData", errorSubtitle: "chargeDischarge_alert_dischargeNotHigher"))
                    }
                }
                return UseCaseResponse.ok(PreValidateChargeDischargeAmountUseCaseOkOutput())
            case .error(let error):
                if let genericError = getGenericError(error: error) {
                    return UseCaseResponse.error(PreValidateChargeDischargeAmountUseCaseErrorOutput(errorTitle: "generic_alert_title_errorData", errorSubtitle: genericError))
                }
            }
        }
        return UseCaseResponse.error(PreValidateChargeDischargeAmountUseCaseErrorOutput(errorTitle: "generic_alert_title_errorData", errorSubtitle: "generic_alert_text_errorAmount"))
    }
    
    private func getGenericError(error: Decimal.DecimalParserAmountError) -> String? {
        switch error {
        case .null:
            return "generic_alert_text_errorAmount"
        case .notValid:
            return "mobileRechange_alert_text_importNotValid"
        case .zero:
            return "generic_alert_text_errorData_amount"
        }
    }
}

struct PreValidateChargeDischargeAmountUseCaseOkOutput {
}

struct PreValidateChargeDischargeAmountUseCaseInput {
    let card: Card
    let type: ChargeDischargeType
}

class PreValidateChargeDischargeAmountUseCaseErrorOutput: StringErrorOutput {
    let errorTitle: String
    let minAmount: Double?
    let maxAmount: Double?
    
    init(errorTitle: String, errorSubtitle: String, minAmount: Double? = nil, maxAmount: Double? = nil) {
        self.errorTitle = errorTitle
        self.minAmount = minAmount
        self.maxAmount = maxAmount
        super.init(errorSubtitle)
    }
}
