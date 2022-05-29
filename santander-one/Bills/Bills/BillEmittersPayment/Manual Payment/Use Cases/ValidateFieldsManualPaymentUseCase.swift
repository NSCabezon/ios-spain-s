//
//  ValidateFieldsManualPaymentUseCase.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 26/05/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateFieldsManualPaymentUseCase: UseCase<GetValidateFieldsManualPaymentUseCaseInput, Void, ValidatedFieldsError> {
    
    override func executeUseCase(requestValues: GetValidateFieldsManualPaymentUseCaseInput) throws -> UseCaseResponse<Void, ValidatedFieldsError> {
        let fields = requestValues.fields
        let amount = requestValues.amount
        let amountDecimal = amount.stringToDecimal
        let errors = ValidatedFieldsError()
        let amountIdentifier = "AMOUNT"
        if amount.isEmpty {
            let styledText: LocalizedStylableText = localized("generic_alert_text_errorAmount")
            errors.append((amountIdentifier, styledText.text))
        }
        
        if amountDecimal?.isZero ?? false {
            let styledText: LocalizedStylableText = localized("generic_alert_text_errorData_amount")
            errors.append((amountIdentifier, styledText.text))
        }
        
        if !isNumeric(string: amount) {
            let styledText: LocalizedStylableText = localized("generic_alert_text_errorData_numberAmount")
            errors.append((amountIdentifier, styledText.text))
        }
        
        for (key, values) in fields {
            if Int(key.fieldLength) != values.count {
                let styledText: LocalizedStylableText = localized("receiptsAndTaxes_alert_numericCode", [
                    StringPlaceholder(.value, key.fieldDescription.capitalized),
                    StringPlaceholder(.number, key.fieldLength)
                ])
                errors.append((key.fieldDescription, styledText.text))
            }
        }
        guard errors.isEmpty else {
            return .error(errors)
        }
        return UseCaseResponse.ok()
    }
    
    private func isNumeric(string: String) -> Bool {
        if string.rangeOfCharacter(from: .decimalDigits) != nil {
            return true
        }
        return false
    }
}

struct GetValidateFieldsManualPaymentUseCaseInput {
    let amount: String
    let fields: [TaxColletionFieldWithValue]
}

final class ValidatedFieldsError: StringErrorOutput {
    var errors = [(identifier: String, error: String)]()
    
    init() {
        super.init("")
    }
    
    func append(_ error: (identifier: String, error: String)) {
        self.errors.append(error)
    }
    
    var isEmpty: Bool {
        return errors.isEmpty
    }
}
