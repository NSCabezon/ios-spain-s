//
//  CardsTransactionsPDFGeneratorProtocol.swift
//  Cards
//
//  Created by Julio Nieto Santiago on 2/2/22.
//

import Foundation
import CoreFoundationLib

public protocol CardsTransactionsPDFGeneratorProtocol {
    func generatePDF(for card: CardEntity, withFilters: TransactionFiltersEntity?)
}
