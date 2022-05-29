//
//  SecurityActionBuilder+QuickBalance.swift
//  Account
//
//  Created by Rubén Márquez Fernández on 26/4/21.
//

import Foundation
import PersonalArea
import CoreFoundationLib

extension SecurityActionBuilder {
    
    public func addQuickBalance(isQuickBalanceEnabled: Bool, action: PersonalAreaQuickBalanceAction) -> Self {
        // Biometry is mandatory to show quick balance
        guard let biometry = self.userPreference.biometryType, biometry != .none else { return self }
        guard biometry != .error(biometry: .none, error: .biometryNotAvailable) else { return self }
        let quickBalanceAction = SecuritySwitchViewModel(
            nameKey: "personalArea_label_quickerBalance",
            switchState: isQuickBalanceEnabled,
            action: nil,
            tooltipMessage: localized("tooltip_text_personalAreaQuickerBalance"),
            accessibilityIdentifiers: [
                .container: AccessibilitySecurityAreaAction.quickBalanceContainer,
                .action: AccessibilitySecurityAreaAction.quickBalanceAction,
                .tooltip: AccessibilitySecurityAreaAction.quickBalanceTooltipAction
            ],
            customAction: { (completion: @escaping (Bool) -> Void) in
                action.didSelectQuickBalance(completion)
            }
        )
        self.actions.append(quickBalanceAction)
        return self
    }
}
