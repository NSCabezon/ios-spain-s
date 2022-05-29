//
//  CardSelectorListConfiguration.swift
//  Cards
//
//  Created by Tania Castellano Brasero on 16/07/2021.
//

import CoreFoundationLib

public final class CardSelectorListConfiguration {
    let allowedTypes: [CardDOType]
    let titleToolbar: String
    
    public init(allowedTypes: [CardDOType], titleToolbar: String) {
        self.allowedTypes = allowedTypes
        self.titleToolbar = titleToolbar
    }
}
