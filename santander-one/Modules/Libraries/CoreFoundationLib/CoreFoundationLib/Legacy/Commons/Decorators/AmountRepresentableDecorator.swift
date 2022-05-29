//
//  AmountRepresentableDecorator.swift
//  Commons
//
//  Created by David Gálvez Alonso on 9/9/21.
//

import CoreDomain

public enum AmountRepresentableDecoratorCurrencyStyle {
    case symbol
    case code
}

public class AmountRepresentableDecorator {
    let font: UIFont
    let amount: AmountRepresentable
    let currencyStyle: AmountRepresentableDecoratorCurrencyStyle
    let decimalFontSize: CGFloat
    var decimalFont: UIFont?
    
    public static let defaultCurrency = "€"
    
    public init(_ amount: AmountRepresentable, currencyStyle: AmountRepresentableDecoratorCurrencyStyle = .symbol, font: UIFont, decimalFontSize: CGFloat? = nil) {
        self.amount = amount
        self.currencyStyle = currencyStyle
        self.font = font
        self.decimalFontSize = decimalFontSize ?? font.pointSize * 0.5
    }
    
    public init(_ amount: AmountRepresentable, currencyStyle: AmountRepresentableDecoratorCurrencyStyle = .symbol, font: UIFont, decimalFont: UIFont) {
        self.amount = amount
        self.currencyStyle = currencyStyle
        self.font = font
        self.decimalFont = decimalFont
        self.decimalFontSize = decimalFont.pointSize
    }
    
    public func getCurrencyWithoutFormat() -> NSAttributedString? {
        return self.makeAttributeString(with: self.getStringValue(), at: self.getStringValue().count)
    }
    
    public func getFormatedAbsWith1M() -> NSAttributedString? {
        return self.scaleDecimals(self.getAbsFormattedAmountUIWith1M())
    }
    
    public func formatAsMillions() -> NSAttributedString? {
        return self.scaleDecimals(self.getFormattedAmountAsMillions())
    }
    
    public func formatAsMillionsWithoutDecimals() -> NSAttributedString? {
        return NSAttributedString(string: self.getFormattedAmountAsMillions(withDecimals: 0))
    }
    
    public func formatNegative(withDecimal decimal: Int = 0) -> NSAttributedString? {
        let stringValue = self.getFormatNegative(withDecimals: decimal)
        return NSAttributedString(string: stringValue, attributes: [.font: self.font])
    }
    
    public func formatNegativeScaled(withDecimal decimal: Int = 0) -> NSAttributedString? {
        return self.scaleDecimals(self.getFormatNegative(withDecimals: decimal))
    }
    
    public func formatZeroDecimalWithCurrencyDecimalFont() -> NSAttributedString {
        let stringValue = self.getFormattedAmountAsMillions(withDecimals: 0)
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
        let text = getCountryCurrencyFormattedIfNegative(valueFormated: text)
        let range = NSRange(location: position, length: text.count - position)
        guard let decimalPart = text.substring(with: range),
              let nonDecimalPart = text.substring(0, position)
        else { return NSAttributedString(string: text) }
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
    
    private func getCountryCurrencyFormattedIfNegative(valueFormated: String) -> String {
        guard amount.value ?? 0.0 < 0  else {
            return valueFormated
        }
        switch amount.currencyRepresentable?.currencyType {
        case .pound:
            var ukValue = valueFormated.replacingOccurrences(of: "-", with: "")
            ukValue.insert("-", at: ukValue.startIndex)
            return ukValue
        default:
            return valueFormated
        }
    }
    
    private func getCurrencyRepresentation() -> String? {
        guard let currency = amount.currencyRepresentable else { return nil }
        switch currencyStyle {
        case .code:
            return currency.currencyCode
        case .symbol:
            return currency.currencyType.symbol != nil ? currency.getSymbol() : currency.currencyName
        }
    }
}

extension AmountRepresentableDecorator: Currencyble {
    
    public func getFormatedCurrency() -> NSAttributedString? {
        return self.scaleDecimals(self.getStringValue())
    }
    
    public var formattedCurrencyWithoutMillion: NSAttributedString? {
        return self.scaleDecimals(self.getStringValueWithoutMillion())
    }
    
    public var formattedPaddedCurrencyWithoutMillion: NSAttributedString? {
        return scaleDecimals(getStringValue(withDecimal: 2, amountRepresentation: .decimalPadded(decimals: 2)))
    }
    
    public func getFormatedWithCurrencyName() -> NSAttributedString? {
        let currencyName = amount.currencyRepresentable?.currencyName ?? ""
        let formatedAmount = "\(self.getFormattedValue()) \(currencyName)"
        return self.scaleDecimals(formatedAmount)
    }

    public func getFormatedWithCurrencySymbol() -> NSAttributedString? {
        let currencySymbol = amount.currencyRepresentable?.getSymbol() ?? ""
        let formatedAmount = "\(self.getFormattedValue()) \(currencySymbol)"
        return self.scaleDecimals(formatedAmount)
    }
    
    public func getStringValue() -> String {
        return getFormattedAmountAsMillions()
    }
    
    public func getStringValueWithoutMillion() -> String {
        return getStringValue(withDecimal: 2)
    }
    
    public func getStringValue(withDecimal decimal: Int, amountRepresentation: AmountRepresentation? = nil) -> String {
        let valueWithDecimals = getFormattedValue(withDecimals: decimal)
        guard let currencySymbol = getCurrencyRepresentation() else { return valueWithDecimals }
        let decimalValue = self.amount.value.map(NSDecimalNumber.init)
        let amountRepresentation = amountRepresentation ?? .decimal(decimals: decimal)
        return currencyRepresentationFor(amountRepresentation, value: decimalValue, currencySymbol: currencySymbol)
    }
    
    public func getFormatNegative(withDecimals decimals: Int) -> String {
        guard let value = self.amount.value else {
            return ""
        }
        let decimal = NSDecimalNumber(decimal: value)
        var stringValue = currencyRepresentationFor(.decimal(decimals: decimals), value: decimal, currencySymbol: self.amount.currencyRepresentable?.getSymbol() ?? "")
        if decimal != 0 { stringValue.insert("-", at: stringValue.startIndex)}
        return stringValue
    }
    
    public func getFormattedValue(withDecimals numberOfDecimals: Int = 2) -> String {
        let decimal = self.amount.value.map(NSDecimalNumber.init)
        let decimalFormat = formatterForRepresentation(.decimal(decimals: numberOfDecimals))
        return decimal.flatMap(decimalFormat.string) ?? "0"
    }
    
    public func getFormattedValueOrEmpty(withDecimals numberOfDecimals: Int = 2, truncateDecimalIfZero: Bool = false) -> String {
        let decimal = self.amount.value.map(NSDecimalNumber.init)
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
        guard let value = self.amount.value else {
            return ""
        }
        let decimal = NSDecimalNumber(decimal: abs(value))
        return formatterForRepresentation(.decimal()).string(from: decimal) ?? "0"
    }
    
    public func getAbsFormattedAmountUI() -> String {
        let symbol = self.amount.currencyRepresentable?.getSymbol() ?? ""
        guard let value = self.amount.value else { return "" }
        let decimal = NSDecimalNumber(decimal: abs(value))
        return currencyRepresentationFor(.decimal(), value: decimal, currencySymbol: symbol)
    }
    
    public func getFormattedAmountUI() -> String {
        let symbol = self.amount.currencyRepresentable?.getSymbol() ?? ""
        return currencyRepresentationFor(.decimal(), value: self.amount.value.map(NSDecimalNumber.init), currencySymbol: symbol)
    }
    
    public func getFormattedValueOrEmptyUI(withDecimals numberOfDecimals: Int = 2, truncateDecimalIfZero: Bool = false) -> String {
        let amount = getFormattedValueOrEmpty(withDecimals: numberOfDecimals, truncateDecimalIfZero: truncateDecimalIfZero)
        let symbol = self.amount.currencyRepresentable?.getSymbol() ?? ""
        return "\(amount)\(symbol)"
    }
    
    public func getAbsFormattedAmountUIWith1M() -> String {
        guard let value = self.amount.value else {
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
        guard let value = self.amount.value else {
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
        guard let value = self.amount.value else {
            return ""
        }
        if abs(value) >= NumberFormattingHandler.shared.millionsThreshold {
            return formatCurrencyWith1M(value: value)
        }
        return getStringValue(withDecimal: decimals)
    }
    
    private func formatCurrencyWith1M(value: Decimal) -> String {
        let decimal = NSDecimalNumber(decimal: value/NumberFormattingHandler.shared.millionsThreshold)
        let symbol = self.amount.currencyRepresentable?.getSymbol() ?? ""
        let valueCurrency = currencyRepresentationFor(.with1M, value: decimal, currencySymbol: symbol)
        return valueCurrency
    }
    
    public func getFormattedTrackValue() -> String {
        let decimal = self.amount.value.map(NSDecimalNumber.init)
        let decimalFormat = formatterForRepresentation(.decimalTracker(decimals: 2))
        return decimal.flatMap(decimalFormat.string) ?? "0.00"
    }
    
    public func getFormattedServiceValue() -> String {
        let decimal = self.amount.value.map(NSDecimalNumber.init)
        let decimalFormat = formatterForRepresentation(.decimalServiceValue(decimals: 2))
        return decimal.flatMap(decimalFormat.string) ?? "0.00"
    }
}
