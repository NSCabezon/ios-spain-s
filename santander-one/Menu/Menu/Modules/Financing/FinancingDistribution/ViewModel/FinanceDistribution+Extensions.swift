//
//  FinanceDistributionItem.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 31/08/2020.
//

import CoreFoundationLib

extension FinancialDistributionType {
    public var iconName: String {
        switch self {
        case .creditCards:
            return "icnCardOperationsDarkTurqLight"
        case .personalLoans:
            return "icnRequestMoneyLime"
        }
    }
    
    public var localizedKey: String {
        switch self {
        case .creditCards:
            return "financing_label_creditCards"
        case .personalLoans:
            return "financing_label_personalLoans"
        }
    }
    
    public var sectorColor: UIColor {
        switch self {
        case .creditCards:
            return .fadedBlue
        case .personalLoans:
            return .seafoamBlue
        }
    }
    
    public var titleAccessibilityIdentifier: String {
        switch self {
        case .creditCards:
            return ".financing_label_creditCards"
        case .personalLoans:
            return "financing_label_personalLoans"
        }
    }
    
    public var amountAccessibilityIdentifier: String {
        switch self {
        case .creditCards:
            return "financingDistributionLabelCardAmount"
        case .personalLoans:
            return "financingDistributionLabelLoanAmount"
        }
    }
}
