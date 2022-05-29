//
//  EasyPayContractTransactionRepresentable+Extension.swift
//  Cards
//
//  Created by Gloria Cano López on 8/4/22.
//

import CoreFoundationLib
import CoreDomain

extension EasyPayContractTransactionRepresentable {
    var transactionPk: CardTransactionPkProtocol {
        get {
            return self.transactionPk
        }
        set {
            self.transactionPk = newValue
        }
    }
}
