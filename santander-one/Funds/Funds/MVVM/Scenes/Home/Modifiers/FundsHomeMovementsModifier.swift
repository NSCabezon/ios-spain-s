//
//  FundsHomeMovementsModifier.swift
//  Funds
//

import CoreDomain

public protocol FundsHomeMovementsModifier {
    var isMoreDetailInfoEnabled: Bool { get }
    func getUnits(for movement: FundMovementRepresentable) -> String?
}
