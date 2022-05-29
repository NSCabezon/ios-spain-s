//
//  AmountDecorator.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 10/15/19.
//

import Foundation

extension Decimal {
    public func getStringValue() -> String {
        return NSDecimalNumber(decimal: self).stringValue
    }
    
    public func getLocalizedStringValue() -> String {
        let value = NSDecimalNumber(decimal: self)
        let decimalFormat = formatterForRepresentation(.decimal(decimals: 2))
        return decimalFormat.string(from: value) ?? "0"
    }
    
    public func decorateAmount(_ symbol: String) -> String {
        let millions = NumberFormattingHandler.shared.millionsThreshold
        if abs(self) >= millions {
            let decimal = NSDecimalNumber(decimal: self/millions)
            let valueCurrency = currencyRepresentationFor(.with1M, value: decimal, currencySymbol: symbol)
            return valueCurrency
        } else {
            let decimal = NSDecimalNumber(decimal: self)
            return currencyRepresentationFor(.decimal(), value: decimal, currencySymbol: symbol)
        }
    }
}

extension AmountEntity: Currencyble {
    public func getFormatedCurrency() -> NSAttributedString? {
        return nil
    }
    
    public func getStringValue() -> String {
        return getFormattedAmountAsMillions()
    }
    
    public func getStringValueWithoutMillion() -> String {
        return getStringValue(withDecimal: 2)
    }
    
    public func getStringValue(withDecimal decimal: Int) -> String {
        let valueWithDecimals = getFormattedValue(withDecimals: decimal)
        guard let currency = dto.currency else { return valueWithDecimals }
        let decimalValue = dto.value.map(NSDecimalNumber.init)
        let valueFormated = currencyRepresentationFor(.decimal(decimals: decimal), value: decimalValue, currencySymbol: currency.currencyType.symbol != nil ? currency.getSymbol() : currency.currencyName)
        return self.getCountryCurrencyFormattedIfNegative(valueFormated: valueFormated)
    }
    
    private func getCountryCurrencyFormattedIfNegative(valueFormated: String) -> String {
        guard dto.value ?? 0.0 < 0  else {
            return valueFormated
        }
        switch dto.currency?.currencyType {
        case .pound:
            var ukValue = valueFormated.replacingOccurrences(of: "-", with: "")
            ukValue.insert("-", at: ukValue.startIndex)
            return ukValue
        default:
            return valueFormated
        }
    }
    
    public func getFormatNegative(withDecimals decimals: Int) -> String {
        guard let value = dto.value else {
            return ""
        }
        let decimal = NSDecimalNumber(decimal: value)
        var stringValue = currencyRepresentationFor(.decimal(decimals: decimals), value: decimal, currencySymbol: dto.currency?.getSymbol() ?? "")
        if decimal != 0 { stringValue.insert("-", at: stringValue.startIndex)}
        return stringValue
    }

    public func getFormattedValue(withDecimals numberOfDecimals: Int = 2) -> String {
        let decimal = dto.value.map(NSDecimalNumber.init)
        let decimalFormat = formatterForRepresentation(.decimal(decimals: numberOfDecimals))
        return decimal.flatMap(decimalFormat.string) ?? "0"
    }
    
    public func getFormattedValueOrEmpty(withDecimals numberOfDecimals: Int = 2, truncateDecimalIfZero: Bool = false) -> String {
        let decimal = dto.value.map(NSDecimalNumber.init)
        var decimalPartIsZero: Bool = false
        guard decimal != 0 else { return "" }
        if truncateDecimalIfZero {
            guard let decimalValue = decimal else {
                return ""
            }
            let decimalPart = modf(decimalValue.doubleValue).1
            decimalPartIsZero = (decimalPart == 0)
        }
        let decimalFormat = formatterForRepresentation(.decimal(decimals: decimalPartIsZero == true ? 0 : numberOfDecimals))
        return decimal.flatMap(decimalFormat.string) ?? ""
    }
    
    public func getAbsFormattedValue() -> String {
        guard let value = dto.value else {
            return ""
        }
        let decimal = NSDecimalNumber(decimal: abs(value))
        return formatterForRepresentation(.decimal()).string(from: decimal) ?? "0"
    }
    
    public func getAbsFormattedAmountUI() -> String {
        let symbol = dto.currency?.getSymbol() ?? ""
        guard let value = dto.value else { return "" }
        let decimal = NSDecimalNumber(decimal: abs(value))
        return currencyRepresentationFor(.decimal(), value: decimal, currencySymbol: symbol)
    }
    
    public func getFormattedAmountUI() -> String {
        let symbol = dto.currency?.getSymbol() ?? ""
        return currencyRepresentationFor(.decimal(), value: dto.value.map(NSDecimalNumber.init), currencySymbol: symbol)
    }

    public func getFormattedValueOrEmptyUI(withDecimals numberOfDecimals: Int = 2, truncateDecimalIfZero: Bool = false) -> String {
        let amount = getFormattedValueOrEmpty(withDecimals: numberOfDecimals, truncateDecimalIfZero: truncateDecimalIfZero)
        let symbol = dto.currency?.getSymbol() ?? ""
        return "\(amount)\(symbol)"
    }

    public func getAbsFormattedAmountUIWith1M() -> String {
        guard let value = dto.value else {
            return ""
        }
        if abs(value) >= NumberFormattingHandler.shared.millionsThreshold {
            return formatCurrencyWith1M(value: abs(value))
        }
        return getAbsFormattedAmountUI()
    }
    
    public func getAbsFormattedAmountUIWithoutMillion() -> String {
        return getAbsFormattedAmountUI()
    }
    
    public func getFormattedAmountUIWith1M() -> String {
        guard let value = dto.value else {
            return ""
        }
        if abs(value) >= NumberFormattingHandler.shared.millionsThreshold {
            return formatCurrencyWith1M(value: value)
        }
        return getFormattedAmountUI()
    }
    
    public func getFormattedAmountAsMillions() -> String {
        return getFormattedAmountAsMillions(withDecimals: 2)
    }
    
    public func getFormattedAmountAsMillions(withDecimals decimals: Int) -> String {
        guard let value = dto.value else {
            return ""
        }
        if abs(value) >= NumberFormattingHandler.shared.millionsThreshold {
            return formatCurrencyWith1M(value: value)
        }
        return getStringValue(withDecimal: decimals)
    }
    
    private func formatCurrencyWith1M(value: Decimal) -> String {
        let decimal = NSDecimalNumber(decimal: value/NumberFormattingHandler.shared.millionsThreshold)
        let symbol = dto.currency?.getSymbol() ?? ""
        let valueCurrency = currencyRepresentationFor(.with1M, value: decimal, currencySymbol: symbol)
        return valueCurrency
    }
    
    public func getFormattedTrackValue() -> String {
        let decimal = dto.value.map(NSDecimalNumber.init)
        let decimalFormat = formatterForRepresentation(.decimalTracker(decimals: 2))
        return decimal.flatMap(decimalFormat.string) ?? "0.00"
    }
    
    public func getFormattedServiceValue() -> String {
        let decimal = dto.value.map(NSDecimalNumber.init)
        let decimalFormat = formatterForRepresentation(.decimalServiceValue(decimals: 2))
        return decimal.flatMap(decimalFormat.string) ?? "0.00"
    }
}

protocol AmountDecorator {
    var amount: Currencyble {get}
}

public class MoneyDecorator: AmountDecorator {

    let font: UIFont
    let amount: Currencyble
    let decimalFontSize: CGFloat
    var decimalFont: UIFont?
    
    public static let defaultCurrency = "€"
    
    public init(_ amount: Currencyble, font: UIFont, decimalFontSize: CGFloat? = nil) {
        self.amount = amount
        self.font = font
        self.decimalFontSize = decimalFontSize ?? font.pointSize * 0.5
    }
    
    public init(_ amount: Currencyble, font: UIFont, decimalFont: UIFont) {
        self.amount = amount
        self.font = font
        self.decimalFont = decimalFont
        self.decimalFontSize = decimalFont.pointSize
    }
    
    @available(iOS 11.0, *)
    public init(_ amount: Currencyble, fontScaled: UIFont, decimalFontScaled: UIFont? = nil, decimalFontSize: CGFloat? = nil) {
        self.amount = amount
        self.font = UIFontMetrics.default.scaledFont(for: fontScaled)
        self.decimalFont = UIFontMetrics.default.scaledFont(for: decimalFontScaled ?? UIFont())
        self.decimalFontSize = decimalFontSize ?? font.pointSize * 0.5
    }
    
    public func getFormatedCurrency() -> NSAttributedString? {
        return self.scaleDecimals(self.amount.getStringValue())
    }
    
    public func getFormattedStringWithoutMillion() -> NSAttributedString? {
        return self.scaleDecimals(self.amount.getStringValueWithoutMillion())
    }

    public func getCurrencyWithoutFormat() -> NSAttributedString? {
        return self.makeAttributeString(with: self.amount.getStringValue(), at: self.amount.getStringValue().count)
    }
    
    public var formattedNotScaledWithoutMillion: NSAttributedString? {
        return self.makeAttributeString(with: self.amount.getStringValueWithoutMillion(), at: self.amount.getStringValueWithoutMillion().count)
    }
    
    public func getFormatedAbsWith1M() -> NSAttributedString? {
        return self.scaleDecimals(self.amount.getAbsFormattedAmountUIWith1M())
    }
    
    public func getFormatedAbsWithoutMillion() -> NSAttributedString? {
        return self.scaleDecimals(self.amount.getAbsFormattedAmountUIWithoutMillion())
    }

    public func formatAsMillions() -> NSAttributedString? {
        return self.scaleDecimals(self.amount.getFormattedAmountAsMillions())
    }
    
    public func formatAsMillionsWithoutDecimals() -> NSAttributedString? {
        return NSAttributedString(string: self.amount.getFormattedAmountAsMillions(withDecimals: 0))
    }
    
    public func formatNegative(withDecimal decimal: Int = 0) -> NSAttributedString? {
        let stringValue = self.amount.getFormatNegative(withDecimals: decimal)
        return NSAttributedString(string: stringValue, attributes: [.font: self.font])
    }
    
    public func formatNegativeScaled(withDecimal decimal: Int = 0) -> NSAttributedString? {
        return self.scaleDecimals(self.amount.getFormatNegative(withDecimals: decimal))
    }
    
    public func formatZeroDecimalWithCurrencyDecimalFont() -> NSAttributedString {
        let stringValue = self.amount.getFormattedAmountAsMillions(withDecimals: 0)
        let newStringValue = NSMutableAttributedString(string: stringValue)
        let attributes: [NSAttributedString.Key: Any]
        if let decimalFont = self.decimalFont {
            attributes = [NSAttributedString.Key.font: decimalFont]
        } else {
            attributes = [NSAttributedString.Key.font: self.font.withSize(self.decimalFontSize)]
        }
        newStringValue.addAttributes(attributes, range: NSRange(location: stringValue.count - 1, length: 1))
        return newStringValue
    }
    
    private func scaleDecimals(_ stringValue: String) -> NSAttributedString? {
        if stringValue.isEmpty {
            return NSAttributedString(string: stringValue)
        } else if stringValue.contains("M") {
            return NSAttributedString(string: stringValue, attributes: [.font: self.font])
        } else if let position = stringValue.distanceFromStart(to: NumberFormattingHandler.shared.getDecimalSeparator()) {
            return makeAttributeString(with: stringValue, at: position)
        }
        return nil
    }
    
    private func makeAttributeString(with text: String, at position: Int) -> NSAttributedString? {
        let range = NSRange(location: position, length: text.count - position)
        guard
            let decimalPart = text.substring(with: range),
            let nonDecimalPart = text.substring(0, position)
            else {
                return NSAttributedString(string: text)
        }
        let builder = TextStylizer.Builder(fullText: text)
        let decimalStyleFont: UIFont
        if let decimalFont = self.decimalFont {
            decimalStyleFont = decimalFont
        } else {
            decimalStyleFont = self.font.withSize(decimalFontSize)
        }
        return builder
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: nonDecimalPart).setStyle(self.font))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: decimalPart).setStyle(decimalStyleFont))
            .build()
    }
}

extension String {
    public func amountAndCurrency() -> String {
        return currencyDefaultSymbolRepresentation(formattedValue: self)
    }
    
    public func amountAndCurrencyWithDecimals() -> String {
        let format = formatterForRepresentation(.decimal(decimals: 2))
        let toNumber = format.number(from: self) ?? 0
        let toFormattedString = format.string(from: toNumber) ?? ""
        return currencyDefaultSymbolRepresentation(formattedValue: toFormattedString)
    }
}
