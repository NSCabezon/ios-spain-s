//
//  EasyPayRepresentable.swift
//  CoreDomain
//
//  Created by Gloria Cano López on 6/4/22.
//

public protocol EasyPayRepresentable {
    var issueDate: Date? { get }
    var paymentMethod: String? { get }
    var productSubtypeRepresentable: ProductSubtypeRepresentable? { get }
    var feeVariationType: String? { get }
    var supportCode: String? { get }
    var transactionOperationModeType: String? { get }
    var transactionOriginType: String? { get }
    var contractedCommerceName: String? { get }
    var atmCommerceDesc: String? { get }
}

