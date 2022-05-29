//
//  SavingProductOptionType+AccessibilityProtocol.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 11/5/22.
//

import CoreFoundationLib
import CoreDomain

extension SavingProductOptionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .sendMoney:
            return AccessibilitySavingsShortcuts.sendMoney.rawValue
        case .statements:
            return AccessibilitySavingsShortcuts.statementHistory.rawValue
        case .regularPayments:
            return AccessibilitySavingsShortcuts.regularPayments.rawValue
        case .reportCard:
            return AccessibilitySavingsShortcuts.reportCard.rawValue
        case .apply:
            return AccessibilitySavingsShortcuts.apply.rawValue
        case .custom(let identifier):
            return identifier
        }
    }
}
