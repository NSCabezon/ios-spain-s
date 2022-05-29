//
//  CardTransactionConfiguration.swift
//  CoreDomain
//
//  Created by Hernán Villamil on 11/4/22.
//
import CoreFoundation
public protocol CardTransactionViewConfigurationRepresentable {
    var detail: CardDetailRepresentable { get }
    var configuration: CardTransactionDetailConfigRepresentable { get }
    var contract: EasyPayContractTransactionRepresentable? { get }
    var feeData: FeeDataRepresentable { get }
}
