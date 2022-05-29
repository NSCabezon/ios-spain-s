//
//  NumberFormattingProtocols.swift
//  Commons
//
//  Created by José María Jiménez Pérez on 23/6/21.
//
import SANLegacyLibrary

public protocol CurrencyFormatterProvider {
    var defaultCurrency: CurrencyType { get }
    var millionsThreshold: Decimal { get }
    var decimalSeparator: Character { get }
    func assembleCurrencyString(for value: String, with symbol: String, representation: AmountRepresentation) -> CurrencySymbolPosition
}

extension CurrencyFormatterProvider {
     public var millionsThreshold: Decimal {
         return 1000000
     }
 }

public enum CurrencySymbolPosition {
    case left
    case leftPadded
    case right
    case rightPadded
    case rightPaddedWithMillionShort(short: String)
    case custom(formattedString: String)
}

public protocol AmountFormatterProvider {
    func formatterForRepresentation(_ amountRepresentation: AmountRepresentation) -> NumberFormatter?
}
