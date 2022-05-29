import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class PrevalidatePayLaterCardUseCase: UseCase<PrevalidatePayLaterCardUseCaseInput, Void, PrevalidatePayLaterCardUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    private let MINIMUM: Decimal = 25.0
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: PrevalidatePayLaterCardUseCaseInput) throws -> UseCaseResponse<Void, PrevalidatePayLaterCardUseCaseErrorOutput> {
        
        let stringData = requestValues.stringData
        let percentageAmount = requestValues.percentageAmount
        let availableBalance = requestValues.availableBalance
        
        guard let dataDecimal = stringData.stringToDecimal, let amountPercentDecimal = percentageAmount.value, let availableBalanceDecimal = availableBalance.getAbsFormattedValue().stringToDecimal else {
            return UseCaseResponse.error(PrevalidatePayLaterCardUseCaseErrorOutput(PayLaterCodError.invalid))
        }
        
        if stringData.isEmpty {
            return UseCaseResponse.error(PrevalidatePayLaterCardUseCaseErrorOutput(PayLaterCodError.empty))
        } else if dataDecimal.isZero {
            return UseCaseResponse.error(PrevalidatePayLaterCardUseCaseErrorOutput(PayLaterCodError.zero))
        } else if dataDecimal.isLess(than: MINIMUM) && MINIMUM == amountPercentDecimal {
            return UseCaseResponse.error(PrevalidatePayLaterCardUseCaseErrorOutput(PayLaterCodError.minorThanMinimum))
        } else if dataDecimal.isLess(than: amountPercentDecimal) && amountPercentDecimal == amountPercentDecimal {
            return UseCaseResponse.error(PrevalidatePayLaterCardUseCaseErrorOutput(PayLaterCodError.minorThanPercent))
        } else if dataDecimal > availableBalanceDecimal {
            return UseCaseResponse.error(PrevalidatePayLaterCardUseCaseErrorOutput(PayLaterCodError.greaterThanAvailableBalance))
        }
        
        return UseCaseResponse.ok()
    }
}

struct PrevalidatePayLaterCardUseCaseInput {
    let percentageAmount: Amount
    let availableBalance: Amount
    let stringData: String
}

enum PayLaterCodError {
    case empty
    case zero
    case minorThanMinimum
    case minorThanPercent
    case greaterThanAvailableBalance
    case invalid
}

protocol PayLaterErrorProvider {
    var payLaterError: PayLaterCodError { get }
}

class PrevalidatePayLaterCardUseCaseErrorOutput: StringErrorOutput, PayLaterErrorProvider {
    let payLaterError: PayLaterCodError
    
    init(_ payLaterError: PayLaterCodError) {
        self.payLaterError = payLaterError
        super.init("")
    }
}
