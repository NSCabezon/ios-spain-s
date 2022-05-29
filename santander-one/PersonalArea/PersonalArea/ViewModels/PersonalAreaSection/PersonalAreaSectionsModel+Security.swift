//
//  PersonalAreaSectionsModel+Security.swift
//  PersonalArea
//
//  Created by Rubén Márquez Fernández on 16/4/21.
//

import Foundation
import CoreFoundationLib

extension PersonalAreaSection {
    public func getGeoCell(_ userPref: UserPrefWrapper?) -> CellInfo {
        return CellInfo(cellClass: "SwitchGenericTableViewCell",
                        info: GenericCellModel(titleKey: "personalArea_label_geolocation",
                                               valueInfo: (
                                                userPref?.isGeolocalizationEnabled ?? false,
                                                AccessibilitySecuritySectionPersonalArea.securitySectionViewGeolocationSwitch
                                               ),
                                               accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnGeolocation),
                        action: .geolocalization)
    }
    
    public func getSecureDeviceCell() -> CellInfo {
        return CellInfo(cellClass: "ArrowGenericTableViewCell",
                        info: GenericCellModel(titleKey: "personalArea_label_secureDevice",
                                               accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnSecureDevice),
                        goToSection: .secureDevice)
    }
    
    public func getOperativeUserCell(_ userPref: UserPrefWrapper?) -> CellInfo {
        let userType: String = (userPref?.isOperativeUser ?? true) ? localized("personalArea_label_operative") : localized("personalArea_label_advisory")
        return CellInfo(cellClass: "ArrowGenericTableViewCell",
                        info: GenericCellModel(
                            titleKey: "personalArea_label_user",
                            tooltipInfo: (
                                localized("tooltip_text_personalAreaUser"),
                                AccessibilitySecuritySectionPersonalArea.securitySectionBtnOperativeTooltip
                            ),
                            valueInfo: (
                                userType,
                                AccessibilitySecuritySectionPersonalArea.securitySectionLabelSelectedUser
                            ),
                            accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnUser),
                        goToSection: .operativeUser)
    }
    
    public func getChangePasswordCell() -> CellInfo {
        return CellInfo(cellClass: "ArrowGenericTableViewCell",
                        info: GenericCellModel(titleKey: "personalArea_label_passwordSignatureKey",
                                               accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnMagicSignatureKey),
                        goToSection: .changePassword)
    }
    
    public func getSignatureKeyCell() -> CellInfo {
        return CellInfo(cellClass: "ArrowGenericTableViewCell",
                        info: GenericCellModel(titleKey: "personalArea_label_signatureKey",
                                               accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnSignatureKey),
                        goToSection: .signature)
    }
    
    public func getEditGDPRCell() -> CellInfo {
        return CellInfo(cellClass: "ArrowGenericTableViewCell",
                        info: GenericCellModel(titleKey: "personalArea_label_privacy",
                                               accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnPrivacy),
                        goToSection: .editGDPR)
    }
    
    public func getLastAccessCell(_ lastAccessInfoViewModel: LastLogonViewModel) -> CellInfo {
        return CellInfo(cellClass: "LastAccessTableViewCell", info: lastAccessInfoViewModel)
    }
}
