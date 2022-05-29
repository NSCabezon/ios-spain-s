//
//  BillEmittersPaymentOperativeData.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/14/20.
//

import Foundation
import CoreFoundationLib

final class BillEmittersPaymentOperativeData {
    var accounts: [AccountEntity] = []
    var selectedAccount: AccountEntity?
    var selectedIncome: IncomeEntity?
    var selectedEmitter: EmitterEntity?
    var formats: ConsultTaxCollectionFormatsEntity?
    var amount: AmountEntity?
    var fields: [TaxColletionFieldWithValue] = []
    var faqs: [FaqsEntity]?

    init(selectedAccount: AccountEntity?) {
        self.selectedAccount = selectedAccount
    }
}
