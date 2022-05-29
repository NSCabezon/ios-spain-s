//
//  FundMovementDetailsFieldsModifier.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 25/4/22.
//

import CoreDomain

public protocol FundMovementDetailFieldsModifier {
    func getDetailFields(for fund: FundRepresentable, movement: FundMovementRepresentable, detail: FundMovementDetailRepresentable?) -> [FundMovementDetailsInfoModel]?
}
