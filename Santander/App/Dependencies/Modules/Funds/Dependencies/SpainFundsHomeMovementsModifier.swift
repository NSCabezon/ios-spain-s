//
//  SpainFundsHomeMovementsModifier.swift
//  Santander
//
//  Created by Ernesto Fernandez Calles on 25/4/22.
//

import Funds
import CoreDomain

final class SpainFundsHomeMovementsModifier: FundsHomeMovementsModifier {
    var isMoreDetailInfoEnabled: Bool = true

    func getUnits(for movement: FundMovementRepresentable) -> String? {
        guard let units = movement.unitsRepresentable, let numberUnits = Double(units) else { return nil }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        formatter.decimalSeparator = ","
        let numberFormatted = formatter.string(from: NSNumber(value: numberUnits.roundTo(places: 4)))
        return numberFormatted
    }
}
