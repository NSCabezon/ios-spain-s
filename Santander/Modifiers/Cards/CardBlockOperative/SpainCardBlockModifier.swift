//
//  SpainCardBlockModifier.swift
//  Santander
//
//  Created by Laura González on 08/06/2021.
//

import Foundation
import Cards

final class SpainCardBlockModifier: CardBlockModifierProtocol {
    var showCommentReason: Bool = true
    
    func isCardBlockAvailable() -> Bool {
        return false
    }
}
