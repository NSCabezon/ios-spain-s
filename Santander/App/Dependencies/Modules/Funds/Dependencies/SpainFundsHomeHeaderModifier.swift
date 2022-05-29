//
//  SpainFundsHomeHeaderModifier.swift
//  Santander
//
//  Created by Ernesto Fernandez Calles on 21/4/22.
//

import Funds
import CoreDomain

class SpainFundsHomeHeaderModifier: FundsHomeHeaderModifier {
    var isOwnerViewEnabled: Bool = false
    var isProfitabilityDataEnabled: Bool = false
    var isShareButtonEnabled: Bool = true

    func getCustomNumber(for fund: FundRepresentable) -> String? {
        return nil
    }
}
