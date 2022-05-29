import Foundation
import CoreFoundationLib

extension Decimal {
    
    func getFormattedAmountUIWith1M(currencySymbol: String) -> String {
        let millions = NumberFormattingHandler.shared.millionsThreshold
        if self >= millions {
            let decimal = NSDecimalNumber(decimal: self/millions)
            return currencyRepresentationFor(.with1M, value: decimal, currencySymbol: currencySymbol)
        }
        return getFormattedAmountUI(currencySymbol: currencySymbol)
    }
    
    func getFormattedAmountUI(currencySymbol: String, _ numberOfDecimals: Int = 2) -> String {
        return currencyRepresentationFor(.decimal(decimals: numberOfDecimals), value: NSDecimalNumber(decimal: self), currencySymbol: currencySymbol)
    }
    
    func getFormattedDescriptionValue(_ numberOfDecimals: Int = 2) -> String {
        let decimal = NSDecimalNumber(decimal: self)
        return formatterForRepresentation(.description(decimals: numberOfDecimals)).string(from: decimal) ?? "0"
    }
    
    func getFormattedValue(_ numberOfDecimals: Int = 2) -> String {
        let decimal = NSDecimalNumber(decimal: self)
        return formatterForRepresentation(.decimal(decimals: numberOfDecimals)).string(from: decimal) ?? "0"
    }
    
    func getSmartFormattedValue(with numberOfDecimals: Int = 2) -> String {
        let decimal = NSDecimalNumber(decimal: self)
        return formatterForRepresentation(.decimalSmart(decimals: numberOfDecimals)).string(from: decimal) ?? "0"
    }
    
    func getTrackerFormattedValue(with numberOfDecimals: Int = 2) -> String {
        let decimal = NSDecimalNumber(decimal: self)
        return formatterForRepresentation(.decimalTracker()).string(from: decimal) ?? "0"
    }
}
