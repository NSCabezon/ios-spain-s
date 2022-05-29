//
//  ContractRepresentable.swift
//  CoreFoundationLib
//
//  Created by José María Jiménez Pérez on 30/7/21.
//

public protocol ContractRepresentable {
    var bankCode: String? { get }
    var branchCode: String? { get }
    var product: String? { get }
    var contractNumber: String? { get }
    var contratoPK: String? { get }
    var fullContract: String { get }
    var fullContractWithoutSpaces: String { get }
    var formattedValue: String { get }
    var description: String { get }
}

public extension ContractRepresentable {
    var fullContract: String {
        guard let bankCode = bankCode,
              let branchCode = branchCode,
              let contractNumber = contractNumber,
              let product = product
        else { return "" }
        return "\(bankCode) \(branchCode) \(product) \(contractNumber)"
    }
    
    var fullContractWithoutSpaces: String {
        guard let bankCode = bankCode,
              let branchCode = branchCode,
              let contractNumber = contractNumber,
              let product = product
        else { return "" }
        return "\(bankCode)\(branchCode)\(product)\(contractNumber)"
    }
}
