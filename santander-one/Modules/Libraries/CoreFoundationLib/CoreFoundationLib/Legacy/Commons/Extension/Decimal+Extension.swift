import Foundation

public enum MoneyDecoratorFormat {
    case millions
    case millionsWithOutDecimals
    case negative
    case negativeScaled
}

extension Decimal {

    public func toStringWithCurrency() -> String {
        let amountEntity = AmountEntity(value: self)
        return amountEntity.getFormattedAmountAsMillions(withDecimals: 2)
    }
    
    public func percentTendingToHightFromTotal(_ total: Decimal, decimalPlaces: Int = 2) -> Decimal {
        let initialPercent: Decimal = (self * 100 / total)
        let decimalNumber = NSDecimalNumber(decimal: initialPercent)
        let roundedNumber = decimalNumber.doubleValue.roundTo(places: decimalPlaces)
        return Decimal(roundedNumber)
    }
    
    public func getSmartFormattedValue(with numberOfDecimals: Int = 2) -> String {
        let decimal = NSDecimalNumber(decimal: self)
        return formatterForRepresentation(.decimalSmart(decimals: numberOfDecimals)).string(from: decimal) ?? "0"
    }
    
    public func getDecimalFormattedValue(with numberOfDecimals: Int = 2) -> String {
        let decimal = NSDecimalNumber(decimal: self)
        return formatterForRepresentation(.decimal(decimals: numberOfDecimals)).string(from: decimal) ?? "0"
    }
    
    public func rounded(numberOfDecimals scale: Int = 2, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }

    public func getSign(zeroValue: String = "") -> String {
        switch self {
        case ..<0:
            return "-"
        case 0:
            return zeroValue
        default:
            return "+"
        }

    }
    
    public var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
