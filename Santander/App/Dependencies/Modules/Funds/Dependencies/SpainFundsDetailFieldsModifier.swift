//
//  SpainFundsDetailFieldsModifier.swift
//  Santander
//
//  Created by Ernesto Fernandez Calles on 21/4/22.
//

import Funds
import CoreDomain
import CoreFoundationLib

class SpainFundsDetailFieldsModifier: FundsDetailFieldsModifier {

    func getDetailFields(for fund: FundRepresentable, detail: FundDetailRepresentable?) -> [FundDetailSectionModel]? {
        let builder = FundDetailBuilder()
            .addSection()
            .addAssociatedAccount(detail?.associatedAccountRepresentable, shareable: true)
            .addAlias(fund.alias)
            .addOwner(detail?.ownerRepresentable?.camelCasedString)
            .addDescription(detail?.descriptionRepresentable)
            .addValuationDate(detail?.dateOfValuation())
            .addNumberOfUnits(detail?.numberOfUnits())
            .addValueOfAUnit(detail?.valueOfAUnit())
            .addTotalValue(detail?.totalValue())
        return builder.build()
    }
}
