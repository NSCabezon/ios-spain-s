//
//  SubMenuSection.swift
//  CoreFoundationLib
//
//  Created by Boris Chirino Fernandez on 8/3/22.
//

import CoreDomain

struct SubMenuSection: Hashable {
    var titleKey: String?
    var items: [SubMenuItem]
    
    init(representable: PrivateMenuSectionRepresentable) {
        self.titleKey = representable.titleKey
        self.items = representable.items.map({ option in
            return SubMenuItem(titleKey: option.titleKey,
                               icon: option.icon,
                               submenuArrow: option.submenuArrow,
                               elementsCount: option.elementsCount,
                               action: option.action)
        })
    }
}

extension SubMenuSection {
    static func == (lhs: SubMenuSection, rhs: SubMenuSection) -> Bool {
        lhs.titleKey == rhs.titleKey
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(titleKey)
    }
}
