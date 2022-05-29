//
//  ContactDetailItemViewModel.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 06/05/2020.
//

import Foundation
import CoreFoundationLib

enum ContactDetailItemType {
    case detail
    case account
}

struct ContactDetailItemViewModel: Shareable {
    let itemTitleKey: String
    let itemValue: String
    let baseURL: String?
    let accessibilityIdentifier: String?
    let type: ContactDetailItemType
    let accessibilityIdentifierItemValue: String?
    
    init(itemTitleKey: String, itemValue: String, baseURL: String? = nil, accessibilityIdentifier: String? = nil, accessibilityIdentifierItemValue: String? = nil, type: ContactDetailItemType) {
        self.itemTitleKey = itemTitleKey
        self.itemValue = itemValue
        self.baseURL = baseURL
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityIdentifierItemValue = accessibilityIdentifierItemValue
        self.type = type
    }
}

extension ContactDetailItemViewModel {
    func getShareableInfo() -> String {
        return itemValue
    }
}
