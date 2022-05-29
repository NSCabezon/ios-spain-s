//
//  SubMenuItem.swift
//  CoreFoundationLib
//
//  Created by Boris Chirino Fernandez on 8/3/22.
//

import CoreDomain

struct SubMenuItem: Hashable, PrivateSubMenuOptionRepresentable {
    let titleKey: String
    let icon: String?
    let submenuArrow: Bool
    let elementsCount: Int?
    let action: PrivateSubmenuAction
}

extension SubMenuItem {
    static func == (lhs: SubMenuItem, rhs: SubMenuItem) -> Bool {
        lhs.titleKey == rhs.titleKey
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(titleKey)
    }
}
