//
//  Double+Extension.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 04/09/2019.
//

import Foundation

extension Double {
    public func asCurrency(with currencySymbol: String? = Locale.current.currencySymbol) -> String {
        let newPrice = NSNumber(value: self)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        
        if let result = formatter.string(from: newPrice) {
            return result // "123,44"
        }
        
        return String(format: "%@.02f", self)
    }
    
    public  func asString(with decimals: Int) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}
