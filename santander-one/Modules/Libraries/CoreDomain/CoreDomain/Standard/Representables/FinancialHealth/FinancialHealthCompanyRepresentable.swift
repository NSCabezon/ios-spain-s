//
//  FinancialHealthCompanyRepresentable.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 17/2/22.
//

import Foundation

public protocol FinancialHealthCompanyRepresentable {
    var company: String? { get }
    var companyName: String? { get }
    var companyProducts: [FinancialHealthCompanyProductRepresentable]? { get }
    var bankImageUrlPath: String? { get }
    var cardImageUrlPath: String? { get }
}

public protocol FinancialHealthCompanyProductRepresentable {
    var productTypeData: String? { get }
    var productData: [FinancialHealthProductDataRepresentable]? { get }
}

public protocol FinancialHealthProductDataRepresentable {
    var id: String? { get }
    var contractNumber:String? { get }
    var iban: String? { get }
    var contractCode: String? { get }
    var balance: String? { get }
    var currency: String? { get }
    var productName: String? { get }
    var lastUpdateDate: Date? { get }
    var selected: Bool? { get }
    var cardType: String? { get }
    var cardNumber: String? { get }
}

public enum FinancialHealthProductTypeRepresentable: String {
    case accounts = "accounts"
    case creditCards = "creditCards"
}
