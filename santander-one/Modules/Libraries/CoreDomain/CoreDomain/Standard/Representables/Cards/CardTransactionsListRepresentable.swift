//
//  CardTransactionsListRepresentable.swift
//  CoreDomain
//
//  Created by Gloria Cano López on 15/12/21.
//

import Foundation

public protocol CardTransactionsListRepresentable {
    var transactions: [CardTransactionRepresentable]  { get }
    var pagination: PaginationRepresentable?  { get }

}
