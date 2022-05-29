//
//  PersonalAreaSectionsSecurityBuilder.swift
//  PersonalArea
//
//  Created by Rubén Márquez Fernández on 16/4/21.
//

import Foundation
import CoreFoundationLib

final public class PersonalAreaSectionsSecurityBuilder {
    public var cellsInfo: [CellInfo] = []
    public let userPref: UserPrefWrapper?
    public let resolver: DependenciesResolver?
    
    public init(userPref: UserPrefWrapper? = nil, resolver: DependenciesResolver?) {
        self.userPref = userPref
        self.resolver = resolver
    }
    
    private lazy var personalAreaSectionsSecurityModifier: PersonalAreaSectionsSecurityModifierProtocol? = {
        self.resolver?.resolve(forOptionalType: PersonalAreaSectionsSecurityModifierProtocol.self)
    }()
    private var isDisabledUser: Bool {
        guard let isDisabledUser = personalAreaSectionsSecurityModifier?.isDisabledUser else {
            return true
        }
        return isDisabledUser
    }
    private var isEnabledPassword: Bool {
        guard let isEnabledPassword = personalAreaSectionsSecurityModifier?.isEnabledPassword else {
            return true
        }
        return isEnabledPassword
    }
    private var isEnabledSignature: Bool {
        guard let isEnabledSignature = personalAreaSectionsSecurityModifier?.isEnabledSignature else {
            return true
        }
        return isEnabledSignature
    }
    private var isEnabledDataPrivacy: Bool {
        guard let isEnabledDataPrivacy = personalAreaSectionsSecurityModifier?.isEnabledDataPrivacy else {
            return true
        }
        return isEnabledDataPrivacy
    }
    private var isEnabledLastAccess: Bool {
        guard let isEnabledLastAccess = personalAreaSectionsSecurityModifier?.isEnabledLastAccess else {
            return true
        }
        return isEnabledLastAccess
    }
    
    private var isEnabledQuickerBalance: Bool {
        guard let isEnabledQuickerBalance = personalAreaSectionsSecurityModifier?.isEnabledQuickerBalance else {
            return true
        }
        return isEnabledQuickerBalance
    }
    
    public func addBiometryCell(customAction: CustomAction? = nil) -> Self {
        guard let biometryType = userPref?.biometryType else { return self }
        guard biometryType != .error(biometry: .none, error: .biometryNotAvailable) else { return self }
        let titleKey: String
        switch biometryType {
        case .faceId, .error(BiometryTypeEntity.faceId, _):
            titleKey = "personalArea_label_faceId"
        case .touchId, .error(BiometryTypeEntity.touchId, _):
            titleKey = "personalArea_label_touchId"
        case .error, .none:
            titleKey = ""
        }
        var value: (Any, String)?
        if let isAuthEnabled = userPref?.isAuthEnabled {
            value = (isAuthEnabled, AccessibilitySecuritySectionPersonalArea.securitySectionViewBiometrySwitch)
        }
        let cell: CellInfo
        if let customAction = customAction {
            cell = CellInfo(cellClass: "SwitchGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: titleKey,
                                valueInfo: value,
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnBiometry
                            ),
                            action: nil, customAction: { completion in
                                customAction(completion)
                            })
        } else {
            cell = CellInfo(cellClass: "SwitchGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: titleKey,
                                valueInfo: value,
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnBiometry
                            ),
                            action: .touchFaceId)
        }
        
        cellsInfo.append(cell)
        return self
    }
    
    public func addGeoCell() -> Self {
        let cell = CellInfo(cellClass: "SwitchGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "personalArea_label_geolocation",
                                valueInfo: (userPref?.isGeolocalizationEnabled ?? false, AccessibilitySecuritySectionPersonalArea.securitySectionViewGeolocationSwitch),
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnGeolocation
                            ),
                            action: .geolocalization)
        cellsInfo.append(cell)
        return self
    }
    
    public func addSecureDeviceCell() -> Self {
        guard userPref?.isOtpPushEnabled == true else {
            return self
        }
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "personalArea_label_secureDevice",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnSecureDevice
                            ),
                            goToSection: .secureDevice)
        cellsInfo.append(cell)
        return self
    }
    
    public func addOperativeUserCell() -> Self {
        if !isDisabledUser {
            return self
        }
        let userType: String = (userPref?.isOperativeUser ?? true) ? localized("personalArea_label_operative") : localized("personalArea_label_advisory")
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "personalArea_label_user",
                                tooltipInfo: (
                                    localized("tooltip_text_personalAreaUser"),
                                    AccessibilitySecuritySectionPersonalArea.securitySectionBtnOperativeTooltip
                                ),
                                valueInfo: (userType, AccessibilitySecuritySectionPersonalArea.securitySectionLabelSelectedUser),
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnUser
                            ),
                            goToSection: .operativeUser)
        cellsInfo.append(cell)
        return self
    }
    
    public func addQuickerBalanceCell() -> Self {
        if !isEnabledQuickerBalance {
            return self
        }
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "personalArea_label_quickerBalance",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnMagicSignatureKey
                            ),
                            goToSection: .quickerBalance)
        cellsInfo.append(cell)
        return self
    }
    
    public func addChangePasswordCell() -> Self {
        if !isEnabledPassword {
            return addPasswordCell()
        }
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "personalArea_label_passwordSignatureKey",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnMagicSignatureKey
                            ),
                            goToSection: .changePassword)
        cellsInfo.append(cell)
        return self
    }
    
    public func addSignatureKeyCell() -> Self {
        if !isEnabledSignature {
            return addSignature()
        }
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "personalArea_label_signatureKey",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnSignatureKey
                            ),
                            goToSection: .signature)
        cellsInfo.append(cell)
        return self
    }
    
    public func addEditGDPRCell() -> Self {
        if !isEnabledDataPrivacy {
            return addDataPrivacy()
        }
        guard userPref?.manageGDPR == true else {
            return self
        }
        
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "personalArea_label_privacy",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnPrivacy
                            ),
                            goToSection: .editGDPR)
        cellsInfo.append(cell)
        return self
    }
    
    public func addLastAccessCell() -> Self {
        if !isEnabledLastAccess {
            return self
        }
        guard let lastAccessInfoViewModel = userPref?.lastAccessInfo else { return self }
        let cell = CellInfo(cellClass: "LastAccessTableViewCell", info: lastAccessInfoViewModel)
        cellsInfo.append(cell)
        return self
    }
    
    public func build() -> [CellInfo] {
        return cellsInfo
    }
}

extension PersonalAreaSectionsSecurityBuilder {
    public func addPasswordCell() -> Self {
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "personalArea_label_passwordSignatureKey",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnSignatureKey
                            ),
                            goToSection: .password)
        cellsInfo.append(cell)
        return self
    }
    
    public func addChangePIN() -> Self {
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "pl_personalArea_label_changePIN",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnChangePIN
                            ),
                            goToSection: .changePIN)
        cellsInfo.append(cell)
        return self
    }
    
    public func addSignature() -> Self {
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "personalArea_label_signatureKey",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnSignatureKey
                            ),
                            goToSection: .signature)
        cellsInfo.append(cell)
        return self
    }
    
    public func addWayCommunication() -> Self {
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "pl_personalArea_label_wayCommunication",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnWayCommunication
                            ),
                            goToSection: .wayCommunication)
        cellsInfo.append(cell)
        return self
    }
    
    public func addCookiesSettings() -> Self {
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "pl_personalArea_label_cookiesSettings",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnCookiesSettings
                            ),
                            goToSection: .cookiesSettings)
        cellsInfo.append(cell)
        return self
    }
    public func addDataPrivacy() -> Self {
        let cell = CellInfo(cellClass: "ArrowGenericTableViewCell",
                            info: GenericCellModel(
                                titleKey: "personalArea_label_privacy",
                                accessibilityIdentifier: AccessibilitySecuritySectionPersonalArea.securitySectionBtnPrivacy
                            ),
                            goToSection: .dataPrivacy)
        cellsInfo.append(cell)
        return self
    }
}
