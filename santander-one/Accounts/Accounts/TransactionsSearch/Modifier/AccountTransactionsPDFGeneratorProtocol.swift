//
//  AccountTransactionsPDFGeneratorProtocol.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 10/9/21.
//

import Foundation
import CoreFoundationLib

public protocol AccountTransactionsPDFGeneratorProtocol {
    func generatePDF(for account: AccountEntity, withFilters: TransactionFiltersEntity?, withScaSate scaState: ScaState?)
}
