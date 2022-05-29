//
//  FavouriteContactsSearchBarItem.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 24/1/22.
//

import Foundation

enum FavouriteContactsEmptyType {
    case noContacts
    case noResults
}

struct FavouriteContactsEmptyItem {
    let type: FavouriteContactsEmptyType
    
    init(_ type: FavouriteContactsEmptyType) {
        self.type = type
    }
    
    var titleKey: String {
        switch type {
        case .noContacts:
            return "generic_label_empty"
        case .noResults:
            return "generic_label_emptyListResult"
        }
    }
    
    var descriptionKey: String {
        switch type {
        case .noContacts:
            return "sendMoney_label_emptyDontHaveContact"
        case .noResults:
            return "sendMoney_label_emptyDontResultsSearch"
        }
    }
}
