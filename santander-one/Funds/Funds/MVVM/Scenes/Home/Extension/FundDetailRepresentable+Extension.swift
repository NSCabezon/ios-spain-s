//
//  FundDetailRepresentable+Extension.swift
//  Funds
//
//  Created by Simón Aparicio on 7/4/22.
//

import CoreDomain
import CoreFoundationLib

extension FundDetailRepresentable {

    public func dateOfValuation() -> String? {
        self.dateOfValuationRepresentable?.toString("d/M/yyyy")
    }

    public func numberOfUnits() -> String? {
        self.numberOfunitsRepresentable
    }

    public func valueOfAUnit() -> String? {
        guard let balance = self.valueOfAUnitAmountRepresentable.map(AmountEntity.init) else { return nil }
        return balance.getStringValue()
    }

    public func totalValue() -> String? {
        guard let balance = self.totalValueAmountRepresentable.map(AmountEntity.init) else { return nil }
        return balance.getStringValue()
    }
}
