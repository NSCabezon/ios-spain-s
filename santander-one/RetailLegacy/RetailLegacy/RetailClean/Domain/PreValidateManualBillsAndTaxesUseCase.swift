import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class PreValidateManualBillsAndTaxesUseCase: UseCase<PreValidateManualBillsAndTaxesUseCaseInput, PreValidateManualBillsAndTaxesUseCaseOkOutput, PreValidateManualBillsAndTaxesUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: PreValidateManualBillsAndTaxesUseCaseInput) throws -> UseCaseResponse<PreValidateManualBillsAndTaxesUseCaseOkOutput, PreValidateManualBillsAndTaxesUseCaseErrorOutput> {
        let type = requestValues.type
        guard
            let entityCode = requestValues.entityCode,
            let reference = requestValues.reference,
            let id = requestValues.id,
            let amount = requestValues.amount,
            let amountDecimal = amount.stringToDecimal
        else {
            return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.other))
        }
        let amountWithoutSeparator = amount.replace(".", "").replace(",", "")
        
        if entityCode.isEmpty || reference.isEmpty || id.isEmpty || amount.isEmpty {
            return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.empty))
        } else if amountDecimal.isZero {
            return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.amountEqualZero))
        } else if type == .bills {
            if entityCode.count < 11 {
                return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.lessThanMaxEntityCodeBills))
            } else if reference.count < 13 {
                return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.lessThanMaxReferenceBills))
            } else if id.count < 6 {
                return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.lessThanMaxIdBills))
            } else if amountWithoutSeparator.count > 10 {
                return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.amountNotValid))
            }
        } else if type == .taxes {
            if entityCode.count < 6 {
                return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.lessThanMaxEntityCodeTaxes))
            } else if reference.count < 12 {
                return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.lessThanMaxReferenceTaxes))
            } else if id.count < 7 {
                return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.lessThanMaxIdTaxes))
            } else if amountWithoutSeparator.count > 8 {
                return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.amountNotValid))
            }
        } else if !isNumeric(string: entityCode) || !isNumeric(string: reference) || !isNumeric(string: id) || !isNumeric(string: id) {
            return UseCaseResponse.error(PreValidateManualBillsAndTaxesUseCaseErrorOutput(ManualBillsAndTaxesCodError.notNumeric))
        }
        let codeFinal = generateCode(type: type, entityCode: entityCode, reference: reference, id: id, amount: amount)
        return UseCaseResponse.ok(PreValidateManualBillsAndTaxesUseCaseOkOutput(code: codeFinal))
    }
    
    private func isNumeric(string: String) -> Bool {
        if string.rangeOfCharacter(from: .decimalDigits) != nil {
            return true
        }
        return false
    }
    
    private func padLeft(string: String, padString: String, maxNumber: Int) -> String {
        let pad = maxNumber - string.count
        return pad < 1 ? string : "".padding(toLength: pad, withPad: padString, startingAt: 0) + string
    }
    
    private func generateCode(type: BillsAndTaxesTypeOperative, entityCode: String, reference: String, id: String, amount: String) -> String {
        var codeFinal = "", formatType = "", parityDigit = ""
        let appIdentifier = "90"
        let amountFormatter = amount.replace(".", "").replace(",", ".")
        guard let amountDouble = Double(amountFormatter) else { return "" }
        let amountWithDecimals = String(format: "%.2f", amountDouble)
        var amountString = amountWithDecimals.replace(".", "").replace(",", "")
        
        switch type {
        case .bills:
            formatType = "507"
            parityDigit = "0"
            amountString = padLeft(string: amountString, padString: "0", maxNumber: 10)
        case .taxes:
            if id.count == 7 {
                formatType = "502"
                parityDigit = ""
            } else if id.count == 10 {
                formatType = "521"
                parityDigit = "0"
            }
            amountString = padLeft(string: amountString, padString: "0", maxNumber: 8)
        }
        
        codeFinal = appIdentifier + formatType + entityCode + reference + id + amountString + parityDigit
        
        return codeFinal
    }
}

struct PreValidateManualBillsAndTaxesUseCaseInput {
    let type: BillsAndTaxesTypeOperative
    let entityCode: String?
    let reference: String?
    let id: String?
    let amount: String?
}

struct PreValidateManualBillsAndTaxesUseCaseOkOutput {
    let code: String?
}

enum ManualBillsAndTaxesCodError {
    case empty
    case lessThanMaxEntityCodeBills
    case lessThanMaxReferenceBills
    case lessThanMaxIdBills
    case lessThanMaxEntityCodeTaxes
    case lessThanMaxReferenceTaxes
    case lessThanMaxIdTaxes
    case notNumeric
    case amountEqualZero
    case amountNotValid
    case other
}

protocol ManualBillsAndTaxesErrorProvider {
    var manualError: ManualBillsAndTaxesCodError { get }
}

class PreValidateManualBillsAndTaxesUseCaseErrorOutput: StringErrorOutput, ManualBillsAndTaxesErrorProvider {
    var manualError: ManualBillsAndTaxesCodError
    
    init(_ manualError: ManualBillsAndTaxesCodError) {
        self.manualError = manualError
        super.init("")
    }
}
