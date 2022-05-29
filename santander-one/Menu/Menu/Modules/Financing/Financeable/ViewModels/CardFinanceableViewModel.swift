//
//  CardFinanceableViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 07/07/2020.
//

import Foundation
import UI
import CoreFoundationLib

struct CardFinanceableViewModel: DropdownElement, Equatable {
    
    let card: CardEntity
    
    var name: String {
        return self.card.getAliasAndInfo()
    }
}
