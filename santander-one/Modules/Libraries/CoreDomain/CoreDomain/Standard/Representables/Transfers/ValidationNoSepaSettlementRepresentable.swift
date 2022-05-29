//
//  ValidationNoSepaSettlementRepresentable.swift
//  CoreDomain
//
//  Created by Juan Diego Vázquez Moreno on 25/1/22.
//

public protocol ValidationNoSepaSettlementRepresentable {
    var impConcepLiqCompRepresentable: AmountRepresentable? { get }
    var impConcepLiqBenefActRepresentable: AmountRepresentable? { get }
}
