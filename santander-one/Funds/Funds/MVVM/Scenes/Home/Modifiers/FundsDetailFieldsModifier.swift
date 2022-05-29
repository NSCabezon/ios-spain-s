//
//  FundsDetailFieldsModifier.swift
//  Funds
//
//  Created by Simón Aparicio on 6/4/22.
//

import CoreDomain

public protocol FundsDetailFieldsModifier {
    func getDetailFields(for fund: FundRepresentable, detail: FundDetailRepresentable?) -> [FundDetailSectionModel]?
}
