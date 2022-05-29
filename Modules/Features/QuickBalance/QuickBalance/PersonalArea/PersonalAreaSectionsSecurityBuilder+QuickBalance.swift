//
//  PersonalAreaSectionsSecurityBuilder+QuickBalance.swift
//  Account
//
//  Created by Rubén Márquez Fernández on 16/4/21.
//

import PersonalArea
import ESCommons
import CoreFoundationLib

extension PersonalAreaSectionsSecurityBuilder {
    public func addQuickBalanceCell(isQuickBalanceEnabled: Bool, action: PersonalAreaQuickBalanceAction) -> Self {
        guard let biometryType = self.userPref?.biometryType else { return self }
        guard biometryType != .error(biometry: .none, error: .biometryNotAvailable) else { return self }
        let cell = CellInfo(
            cellClass: "SwitchGenericTableViewCell",
            info: GenericCellModel(
                titleKey: "personalArea_label_quickerBalance",
                tooltipInfo: (
                    localized("tooltip_text_personalAreaQuickerBalance"),
                    PersonalAreaSecuritySectionsAccessibilityIdentifier.securitySectionBtnQuickBalanceTooltip
                ),
                valueInfo: (
                    isQuickBalanceEnabled,
                    PersonalAreaSecuritySectionsAccessibilityIdentifier.securitySectionViewQuickBalanceSwitch
                ),
                accessibilityIdentifier: PersonalAreaSecuritySectionsAccessibilityIdentifier.securitySectionBtnQuickBalance
            ),
            action: nil,
            customAction: { (completion: @escaping (Bool) -> Void) in
                action.didSelectQuickBalance(completion)
            }
        )
        cellsInfo.append(cell)
        return self
    }
}
