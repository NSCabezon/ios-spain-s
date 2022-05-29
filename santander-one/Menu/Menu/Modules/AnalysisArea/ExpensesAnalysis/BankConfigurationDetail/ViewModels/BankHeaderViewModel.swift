//
//  BankHeaderViewModel.swift
//  Menu
//
//  Created by Daniel Gómez Barroso on 12/7/21.
//

import Foundation

struct BankHeaderViewModel {
    enum BankHeaderType {
        case accounts, cards
        var titleKey: String {
            switch self {
            case .accounts:
                return "pgBasket_title_accounts"
            case .cards:
                return "pgBasket_title_cards"
            }
        }
    }
    
    let type: BankHeaderType
    var isSelected: Bool
}
