//
//  AmountRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 8/9/21.
//

public protocol AmountRepresentable {
    var value: Decimal? { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var wholePart: String { get }
    func getDecimalPart() -> String
    func getDecimalPart(decimales: Int) -> String
}

public extension AmountRepresentable {
    func getAccessibilityAmountText() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = self.currencyRepresentable?.currencyType.name
        currencyFormatter.currencySymbol = self.currencyRepresentable?.getSymbol()
        if let amountValue = value,
            let amountText = currencyFormatter.string(from: amountValue as NSNumber) {
            return amountText
        }
        return ""
    }
    
    var wholePart: String {
        guard let value = value else { return "" }
        let formatter = NumberFormatter()
        guard let valueFormatted = formatter.withSeparator(decimals: 2).string(from: value as NSNumber),
              let indexDistance = valueFormatted.indexDistance(of: "."),
              let wholePart = valueFormatted.substring(0, indexDistance)
        else { return "" }
        return wholePart
    }

    func getDecimalPart() -> String {
        return getDecimalPart(decimales: 2)
    }

    func getDecimalPart(decimales: Int) -> String {
        guard let value = value else { return "" }
        let formatter = NumberFormatter()
        guard let valueFormatted = formatter.withSeparator(decimals: decimales).string(from: value as NSNumber),
              let indexDistance = valueFormatted.indexDistance(of: "."),
              let decimalPart = valueFormatted.substring(indexDistance + 1, indexDistance + 1 + decimales)
        else { return "" }
        return decimalPart
    }
}

fileprivate extension String {
    func indexDistance(of character: Character) -> Int? {
        guard let index = firstIndex(of: character) else {
            return nil
        }
        return distance(from: startIndex, to: index)
    }
    
    func substring(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else {
            return nil
        }
        return String(self[range])
    }
    
    func substring(_ beginIndex: Int, _ endIndex: Int) -> String? {
        return substring(with: NSRange(location: beginIndex, length: endIndex - beginIndex))
    }
    
    func substring(_ beginIndex: Int) -> String? {
        return substring(with: NSRange(location: beginIndex, length: self.count - beginIndex))
    }
    
    
    func substring(to: PartialRangeUpTo<Int>) -> String {
        return String(self[..<index(startIndex, offsetBy: to.upperBound)])
    }
}


fileprivate extension NumberFormatter {
    func withSeparator(decimals: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        return formatter
    }
}
