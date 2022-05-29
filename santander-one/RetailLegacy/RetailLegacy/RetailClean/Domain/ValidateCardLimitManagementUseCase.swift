import Foundation
import SANLegacyLibrary
import CoreFoundationLib

enum CardLimitErrors {
    case invalidAmount
    case noChange
    case amountMustBeHigher(String)
    case amountMustBeLower(String)
    
    func buildString() -> (String, [StringPlaceholder]?) {
        switch self {
        case .invalidAmount:
            return ("limitsModifyCard_alert_amountError", nil)
        case let .amountMustBeHigher(value):
            return ("limitsModifyCard_alert_sameHigherValue", [StringPlaceholder(.value, String(value))])
        case let .amountMustBeLower(value):
            return ("limitsModifyCard_alert_sameLowerValue", [StringPlaceholder(.value, String(value))])
        case .noChange:
            return ("limitsModifyCard_alert_errorLimitsModify", nil)
        }
    }
}

class ValidateCardLimitManagementUseCase: UseCase<ValidateCardLimitManagementUseCaseInput, Void, ValidateCardLimitManagementUseCaseErrorOutput> {
    
    override func executeUseCase(requestValues: ValidateCardLimitManagementUseCaseInput) throws -> UseCaseResponse<Void, ValidateCardLimitManagementUseCaseErrorOutput> {
        
        let card = requestValues.card
        let currentDailyATMLimit = requestValues.currentATMLimit
        let currentDailyLimit = requestValues.currentLimit
        
        let isDebit = card.isDebitCard && currentDailyATMLimit != nil && currentDailyLimit != nil
        let isCredit = card.isCreditCard && currentDailyATMLimit != nil
        guard isCredit || isDebit else {
            return UseCaseResponse.error(ValidateCardLimitManagementUseCaseErrorOutput(CardLimitErrors.invalidAmount))
        }
        
        let isCreditAndChangedLimit = isCredit && currentDailyATMLimit != card.dailyATMLimit?.value
        let isDebitAndChangedLimit = isDebit && (currentDailyATMLimit != card.dailyATMLimit?.value || currentDailyLimit != card.dailyLimit?.value)
        guard isCreditAndChangedLimit || isDebitAndChangedLimit else {
            return UseCaseResponse.error(ValidateCardLimitManagementUseCaseErrorOutput(CardLimitErrors.noChange))
        }
        
        if let error = validateLimits(currentValue: requestValues.currentATMLimit, lowerLimit: requestValues.minimumATMLimit, higherLimit: requestValues.maximumATMLimit) {
            return UseCaseResponse.error(error)
        }
        
        if isDebit, let error = validateLimits(currentValue: requestValues.currentLimit, lowerLimit: requestValues.minimumLimit, higherLimit: requestValues.maximumLimit) {
            return UseCaseResponse.error(error)
        }
        
        return UseCaseResponse.ok()
    }
    
    private func validateLimits(currentValue: Decimal?, lowerLimit: Decimal?, higherLimit: Decimal?) -> ValidateCardLimitManagementUseCaseErrorOutput? {
        guard let currentLimit = currentValue, let minimumLimit = lowerLimit, let maximumLimit = higherLimit else {
            
            return ValidateCardLimitManagementUseCaseErrorOutput(CardLimitErrors.invalidAmount)
        }
        
        if currentLimit < minimumLimit {
            
            return ValidateCardLimitManagementUseCaseErrorOutput(CardLimitErrors.amountMustBeHigher(
            minimumLimit.getFormattedValue()))
        }
        if currentLimit > maximumLimit {
            
            return ValidateCardLimitManagementUseCaseErrorOutput(CardLimitErrors.amountMustBeLower(maximumLimit.getFormattedValue()))
        }
        
        return nil
    }
}

struct ValidateCardLimitManagementUseCaseInput {
    let card: Card
    let currentATMLimit: Decimal?
    let minimumATMLimit: Decimal?
    let maximumATMLimit: Decimal?
    let currentLimit: Decimal?
    let minimumLimit: Decimal?
    let maximumLimit: Decimal?
}

class ValidateCardLimitManagementUseCaseErrorOutput: StringErrorOutput {
    var errorType: CardLimitErrors
    
    init(_ error: CardLimitErrors) {
        self.errorType = error
        super.init(nil)
    }
}
