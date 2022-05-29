import Foundation
import CoreFoundationLib

extension Decimal {
    enum DecimalParserResult<Error> {
        case success(value: Decimal)
        case error(Error)
    }
    
    enum DecimalParserPercentageError {
        case null
        case notValid
        case zero
    }
    
    enum DecimalParserAmountError {
        case null
        case notValid
        case zero
    }
    
    static func defaultErrorDescriptionKey(forPercentageError percentageError: DecimalParserPercentageError) -> String {
        switch percentageError {
        case .null,
             .notValid:
            return  "generic_error_percentageNull"
        case .zero:
            return "generic_error_percentageMore0"
        }
    }
    
    static func defaultErrorDescriptionKey(forAmountError amountError: DecimalParserAmountError) -> String {
        switch amountError {
        case .null:
            return "generic_alert_text_errorAmount"
        case .notValid:
            return "generic_alert_text_errorData_numberAmount"
        case .zero:
            return "generic_alert_text_errorData_amount"
        }
    }
    
    static func getPercentageParserResult(value: String?) -> DecimalParserResult<DecimalParserPercentageError> {
        guard let text = value else {
            return .error(.null)
        }
        
        guard let decimal = Decimal(string: text.replace(".", "").replace(",", ".")) else {

            return .error(.notValid)
        }
        
        guard decimal > 0.0 else {
            return .error(.zero)
        }
        
        return .success(value: decimal)
    }
    
    static func getAmountParserResult(value: String?) -> DecimalParserResult<DecimalParserAmountError> {
        guard let text = value, text != "" else {
            return .error(.null)
        }
        
        guard let decimal = Decimal(string: text.replace(".", "").replace(",", ".")) else {
            return .error(.notValid)
        }
        
        guard decimal > 0.0 else {
            return .error(.zero)
        }
        
        return .success(value: decimal)
    }
    
    func int64CustomValue() -> Int64? {
        let number = NSNumber(value: doubleValue.doubleRounded(toPlaces: 2) * 100)
        let format = NumberFormatter()
        format.maximumFractionDigits = 2
        guard let result = format.string(from: number) else {
            return nil
        }
        return Int64(result)
    }
}

extension Decimal: OperativeParameter {}
