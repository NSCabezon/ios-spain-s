//
//  CurrencyRepresented.swift
//  Models
//
//  Created by David Gálvez Alonso on 22/10/21.
//

import CoreDomain

public class CurrencyRepresented: CurrencyRepresentable {
    public var currencyCode: String
    public var currencyName: String
    public var currencyType: CurrencyType
    
    public init(currencyName: String? = nil, currencyCode: String) {
        let currencyType = CurrencyType.parse(currencyCode)
        self.currencyName = currencyName ?? currencyType.name
        self.currencyType = currencyType
        self.currencyCode = currencyCode
    }
    
    public func getSymbol() -> String {
        return currencyType.symbol ?? currencyName
    }
}
