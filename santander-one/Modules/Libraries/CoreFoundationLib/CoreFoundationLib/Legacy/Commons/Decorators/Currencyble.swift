//
//  Currencyble.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 10/15/19.
//

import Foundation

public protocol Currencyble {
    func getStringValue() -> String
    func getFormatedCurrency() -> NSAttributedString?
    func getAbsFormattedAmountUIWith1M() -> String
    func getAbsFormattedAmountUIWithoutMillion() -> String
    func getFormattedAmountAsMillions() -> String
    func getFormattedAmountAsMillions(withDecimals decimals: Int) -> String
    func getFormatNegative(withDecimals decimals: Int) -> String
    func getStringValueWithoutMillion() -> String
}
