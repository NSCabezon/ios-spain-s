//
//  FundMovementRepresentable.swift
//  CoreDomain
//

public protocol FundMovementRepresentable {
    var dateRepresentable: Date? { get }
    var submittedDateRepresentable: Date? { get }
    var nameRepresentable: String?  { get }
    var amountRepresentable: AmountRepresentable?  { get }
    var unitsRepresentable: String?  { get }
}
