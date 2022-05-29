//
//  CoreCurrencyFormatterProvider.swift
//  Commons
//
//  Created by José María Jiménez Pérez on 23/6/21.
//

import SANLegacyLibrary

public final class CoreCurrencyFormatterProvider: CurrencyFormatterProvider {
    public func assembleCurrencyString(for value: String, with symbol: String, representation: AmountRepresentation) -> CurrencySymbolPosition {
        switch representation {
        case .with1M:
            return .rightPaddedWithMillionShort(short: "M")
        case .decimalPadded:
            return .rightPadded
        default:
            return .right
        }
    }
    
    public var defaultCurrency: CurrencyType {
        return .eur
    }
    
    public var millionsThreshold: Decimal {
        return 1000000
    }
    
    public var decimalSeparator: Character {
        return ","
    }
}

extension CoreCurrencyFormatterProvider: AmountFormatterProvider {
    public func formatterForRepresentation(_ amountRepresentation: AmountRepresentation) -> NumberFormatter? {
        switch amountRepresentation {
        case .withoutDecimals:
            return generateWithoutDecimals()
        case .with1M:
            return generateWith1M()
        case .decimal(let decimals):
            return generateDecimals(decimals)
        case .decimalPadded(let decimals):
            return generateDecimals(decimals)
        case .decimalTracker(let decimals):
            return generateDecimalTracker(decimals)
        case .decimalServiceValue(let decimals):
            return generateDecimalServiceValue(decimals)
        case .decimalSmart(let decimals):
            return generateDecimalSmart(decimals)
        case .descriptionPFM(let decimals):
            return generateDescriptionPFM(decimals)
        case .description(let decimals):
            return generateDescription(decimals)
        case .wholePart:
            return generateWholePart()
        case .tae(let decimals):
            return generateTae(decimals)
        case .sharesCount5Decimals:
            return generateSharesCount5Decimals()
        case .transactionFilters:
            return generateTransactionFilters()
        case .withSeparator(let decimals):
            return generateWithSeparator(decimals)
        case .amountTextField(let maximumFractionDigits, let maximumIntegerDigits):
            return generateAmountTextField(maximumFractionDigits: maximumFractionDigits, maximumIntegerDigits: maximumIntegerDigits)
        case .default: return NumberFormatter()
        }
    }
}

private extension CoreCurrencyFormatterProvider {
    func generateWithoutDecimals() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de")
        return formatter
    }
    
    func generateWith1M() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.minusSign = "\u{2212}"
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de")
        return formatter
    }
    
    func generateDecimals(_ decimales: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = decimales
        formatter.minimumFractionDigits = decimales
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.minusSign = "\u{2212}"
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de")
        return formatter
    }
    
    func generateDecimalTracker(_ decimales: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = decimales
        formatter.minimumFractionDigits = decimales
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de")
        return formatter
    }
    
    func generateDecimalServiceValue(_ decimals: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de")
        return formatter
    }
    
    func generateDecimalSmart(_ decimales: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = decimales
        formatter.minimumFractionDigits = 0
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.minusSign = "\u{2212}"
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de")
        return formatter
    }
    
    func generateDescriptionPFM(_ decimales: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = decimales
        formatter.minimumFractionDigits = decimales
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        return formatter
    }
    
    func generateDescription(_ decimales: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = decimales
        formatter.minimumFractionDigits = decimales
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de")
        return formatter
    }
    
    func generateWholePart() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 10
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.minusSign = "\u{2212}"
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de")
        return formatter
    }
    
    func generateTae(_ decimals: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        var positiveFormat = "#,##0."
        for _ in 0 ..< decimals {
            positiveFormat.append("0")
        }
        formatter.positiveFormat = positiveFormat
        formatter.negativeFormat = formatter.positiveFormat
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        return formatter
    }
    
    func generateSharesCount5Decimals() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 5
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        return formatter
    }
    
    func generateTransactionFilters() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.alwaysShowsDecimalSeparator = false
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 2
        formatter.maximumIntegerDigits = 6
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.groupingSize = 3
        formatter.roundingMode = .down
        return formatter
    }
    
    func generateWithSeparator(_ decimales: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = decimales
        formatter.minimumFractionDigits = decimales
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        return formatter
    }
    
    func generateAmountTextField(maximumFractionDigits: Int, maximumIntegerDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.alwaysShowsDecimalSeparator = false
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.maximumIntegerDigits = maximumIntegerDigits
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.groupingSize = 3
        formatter.roundingMode = .down
        formatter.locale = Locale(identifier: "de")
        return formatter
    }
}
