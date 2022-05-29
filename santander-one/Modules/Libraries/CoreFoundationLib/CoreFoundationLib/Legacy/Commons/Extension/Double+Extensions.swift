//
//  Double+Extensions.swift
//  Commons
//
//  Created by Boris Chirino Fernandez on 07/09/2020.
//

import Foundation

extension Double {
    public func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded(.toNearestOrAwayFromZero) / divisor
    }
    /**
     As their name state, represent the string value for the finantial agregator zone
     This string will be used on the financial agregator widget (graph and table) on the mentioned above zone.
      - Parameter includePercentSimbol: if true the number will include percent symbol
     */
    public func asFinancialAgregatorPercentText(includePercentSimbol: Bool = true) -> String {
        var format: String = "%.0f%@"
        var argumentValue = self
        let symbol: String = includePercentSimbol ? "%" : ""
        var arguments: [CVarArg] = [symbol]
        switch self {
        case 0...0.49:
            format = "<1%@"
        case 0.50...1:
            format = "1%@"
        default:
            format = "%.0f%@"
            argumentValue = self >= 99.5 ? self.rounded(.towardZero) : self
            arguments = [argumentValue, symbol]
        }
        return String(format: format, arguments: arguments)
    }
}
