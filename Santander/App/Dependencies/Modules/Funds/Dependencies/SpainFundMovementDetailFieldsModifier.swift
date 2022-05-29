//
//  SpainFundMovementDetailFieldsModifier.swift
//  Santander
//
//  Created by Ernesto Fernandez Calles on 25/4/22.
//

import Funds
import CoreDomain
import CoreFoundationLib
import SANLegacyLibrary

class SpainFundMovementDetailFieldsModifier: FundMovementDetailFieldsModifier {

    func getDetailFields(for fund: FundRepresentable, movement: FundMovementRepresentable, detail: FundMovementDetailRepresentable?) -> [FundMovementDetailsInfoModel]? {
        guard let detailDTO = detail as? FundTransactionDetailDTO else {
            return []
        }
        var associatedAccount: String?
        if let ibanChargeIncome = detailDTO.IBANChargeIncome {
            associatedAccount = IBANEntity(ibanChargeIncome).ccc
        }
        let builder = FundMovementDetailsBuilder()
            .addAlias(fund.alias)
            .addAssociatedAccount(associatedAccount)
            .addTransactionFees(detailDTO.operationExpensesAmount.map(AmountEntity.init)?.getStringValue())
            .addStatus(detailDTO.situationDesc)
        return builder.build()
    }
}
