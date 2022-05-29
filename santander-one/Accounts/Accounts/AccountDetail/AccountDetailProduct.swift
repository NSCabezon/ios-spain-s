//
//  AccountDetailProduct.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 15/02/2021.
//

import Foundation

public struct AccountDetailProduct {
    
    enum AccountDetailProductType {
        case tooltip
        case icon
        case basic
        case editable
    }
    
    let title: String
    let value: String
    let type: AccountDetailProductType
    var tooltipText: String?
    var maxAliasLength: Int?
    var regExValidatorString: CharacterSet?
    let titleAccessibilityID: String?
    let valueAccessibilityID: String?
    let tooltipAccesibilityID: String?
    
    init(title: String, value: String, type: AccountDetailProductType, tooltipText: String? = nil, maxAliasLength: Int? = nil, regExValidatorString: CharacterSet? = nil, titleAccessibilityID: String? = nil, valueAccessibilityID: String? = nil, tooltipAccesibilityID: String? = nil) {
        self.title = title
        self.value = value
        self.type = type
        self.tooltipText = nil
        self.maxAliasLength = nil
        self.regExValidatorString = nil
        self.titleAccessibilityID = titleAccessibilityID
        self.valueAccessibilityID = valueAccessibilityID
        self.tooltipAccesibilityID = tooltipAccesibilityID
        if let tooltipText = tooltipText {
            self.tooltipText = tooltipText
        }
        if let maxAliasLength = maxAliasLength {
            self.maxAliasLength = maxAliasLength
        }
        if let regExValidatorString = regExValidatorString {
            self.regExValidatorString = regExValidatorString
        }
    }
}
