//
//  CardTransactionRepresentable+Extension.swift
//  Cards
//
//  Created by Gloria Cano López on 8/4/22.
//

import CoreDomain
import CoreFoundationLib

extension CardTransactionRepresentable {
    var transactionPk: CardTransactionPkProtocol {
        get {
            return self.transactionPk
        }
        set {
            self.transactionPk = newValue
        }
    }
}
