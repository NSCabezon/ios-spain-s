//
//  FundMovementListRepresentable.swift
//  CoreDomain
//

public protocol FundMovementListRepresentable {
    var transactions: [FundMovementRepresentable] { get }
    var next: PaginationRepresentable? { get }
}
