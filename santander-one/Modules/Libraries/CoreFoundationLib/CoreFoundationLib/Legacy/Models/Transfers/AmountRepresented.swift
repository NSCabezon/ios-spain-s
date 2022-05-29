//
//  AmountRepresented.swift
//  Models
//
//  Created by Cristobal Ramos Laina on 21/10/21.
//

import Foundation
import CoreDomain

public class AmountRepresented: AmountRepresentable {
    public var value: Decimal?
    public var currencyRepresentable: CurrencyRepresentable?
    
    public init(value: Decimal, currencyRepresentable: CurrencyRepresentable) {
        self.value = value
        self.currencyRepresentable = currencyRepresentable
    }
}
