//
//  EasyPayContractTransactionListRepresentable.swift
//  CoreDomain
//
//  Created by Gloria Cano López on 6/4/22.
//

public protocol EasyPayContractTransactionListRepresentable {
    var transactions: [EasyPayContractTransactionRepresentable]? { get }
    var paginationRepresentable: PaginationRepresentable?  { get }

}
