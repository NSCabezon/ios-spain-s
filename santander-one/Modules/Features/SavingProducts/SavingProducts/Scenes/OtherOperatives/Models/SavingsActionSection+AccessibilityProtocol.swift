//
//  SavingsActionSection+AccessibilityProtocol.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 11/5/22.
//

import CoreFoundationLib
import CoreDomain

extension SavingsActionSection: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .settings:
            return AccessibilitySavingsShortcutSections.settings.rawValue
        case .queries:
            return AccessibilitySavingsShortcutSections.queries.rawValue
        case .offer:
            return AccessibilitySavingsShortcutSections.offer.rawValue
        }
    }
}
