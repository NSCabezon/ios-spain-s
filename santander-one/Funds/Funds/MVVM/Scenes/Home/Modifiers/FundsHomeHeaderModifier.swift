//
//  FundsHomeHeaderModifier.swift
//  Funds
//

import CoreDomain

public protocol FundsHomeHeaderModifier {
    var isOwnerViewEnabled: Bool { get }
    var isProfitabilityDataEnabled: Bool { get }
    var isShareButtonEnabled: Bool { get }
    func getCustomNumber(for fund: FundRepresentable) -> String?
}
