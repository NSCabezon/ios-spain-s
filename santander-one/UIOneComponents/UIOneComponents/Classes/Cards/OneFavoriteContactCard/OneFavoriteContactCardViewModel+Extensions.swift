//
//  OneFavoriteContactCardViewModel+Extensions.swift
//  UIOneComponents
//
//  Created by Juan Diego Vázquez Moreno on 3/9/21.
//

import CoreFoundationLib

public extension OneFavoriteContactCardViewModel.CardStatus {
    var backgroundColor: UIColor {
        switch self {
        case .inactive:
            return .white
        case .selected:
            return UIColor.turquoise.withAlphaComponent(0.07)
        }
    }
}
