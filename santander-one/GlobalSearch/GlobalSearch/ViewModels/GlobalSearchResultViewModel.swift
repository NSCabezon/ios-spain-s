//
//  File.swift
//  GlobalSearch
//
//  Created by Luis Escámez Sánchez on 26/02/2020.
//

struct GlobalSearchResultMovementViewModel {
    let resultType: GlobalSearchMovementType
    let movement: GlobalSearchMovementViewModel
    
    init(resultType: GlobalSearchMovementType, movement: GlobalSearchMovementViewModel) {
        self.resultType = resultType
        self.movement = movement
    }
}

enum GlobalSearchMovementType {
    case card
    case account
    
    var sectionTitle: String {
        switch self {
        case .card:
            return "search_title_card"
        case .account:
            return "search_title_account"
        }
    }
    
    var sortSectionTitle: String {
        switch self {
        case .card:
            return "search_tag_card"
        case .account:
            return "search_tag_account"
        }
    }
}
