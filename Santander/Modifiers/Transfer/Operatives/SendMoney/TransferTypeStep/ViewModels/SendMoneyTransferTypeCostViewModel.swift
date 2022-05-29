//
//  SendMoneyTransferTypeCostViewModel.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

import CoreDomain
import CoreFoundationLib

struct SendMoneyTransferTypeCostViewModel {
    let type: SpainTransferType
    let instantMaxAmount: AmountRepresentable?
    
    init(type: SpainTransferType,
         instantMaxAmount: AmountRepresentable?) {
        self.type = type
        self.instantMaxAmount = instantMaxAmount
    }
}
