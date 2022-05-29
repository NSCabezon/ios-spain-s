//
//  FinancialHealthCompanyDTO.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 17/2/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

struct FinancialHealthCompanyDTO: Decodable {
    let company: String?
    let companyName: String?
    let products: [FinancialHealthCompanyProductDTO]?
}

struct FinancialHealthCompanyProductDTO: Decodable {
    let productType: String?
    let data: [FinancialHealthProductDataDTO]?
}

struct FinancialHealthProductDataDTO: Decodable {
    let id: String?
    let contractNumber: String?
    let iban: String?
    let contractCode: String?
    let balance: String?
    let currency: String?
    let productName: String?
    let lastUpdate: String?
    let selected: Bool?
    let cardType: String?
    let cardNumber: String?
}
 
extension FinancialHealthCompanyDTO: FinancialHealthCompanyRepresentable {
    var bankImageUrlPath: String? {
        let bankLogoRelativeUrl = FinancialHealthConstants.bankLogoRelativeURl
        let countryCode = "es"
        let logoExtension = FinancialHealthConstants.iconBankExtension
        guard let companyCode = company else { return "" }
        return "\(bankLogoRelativeUrl)\(countryCode)_\(companyCode)\(logoExtension)"
    }
    
    var cardImageUrlPath: String? {
        let bankLogoRelativeUrl = FinancialHealthConstants.cardLogoRelativeURl
        let countryCode = "es"
        let logoExtension = FinancialHealthConstants.iconBankExtension
        guard let companyCode = company else { return "" }
        return "\(bankLogoRelativeUrl)\(countryCode)_\(companyCode)\(logoExtension)"
    }
    
    var companyProducts: [FinancialHealthCompanyProductRepresentable]? {
        self.products
    }
}

extension FinancialHealthCompanyProductDTO: FinancialHealthCompanyProductRepresentable {
    var productTypeData: String? {
        self.productType
    }
    
    var productData: [FinancialHealthProductDataRepresentable]? {
        self.data
    }
}

extension FinancialHealthProductDataDTO: FinancialHealthProductDataRepresentable {
    var lastUpdateDate: Date? {
        self.lastUpdate?.toDate(dateFormat: TimeFormat.yyyy_MM_ddTHHmmssSSSSSS.rawValue)
    }
}
