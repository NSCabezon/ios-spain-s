//
//  PreconceivedBannerViewModel.swift
//  GlobalPosition
//
//  Created by Laura González on 21/07/2020.
//

import CoreFoundationLib

public struct PreconceivedBannerViewModel {
    let amount: Float
    
    public init(amount: Float) {
        self.amount = amount
    }
    
    var amountEntity: AmountEntity {
        return AmountEntity(value: Decimal(Double(self.amount)))
    }
}
