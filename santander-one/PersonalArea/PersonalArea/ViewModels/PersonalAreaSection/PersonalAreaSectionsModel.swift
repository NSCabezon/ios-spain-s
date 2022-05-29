//
//  PersonalAreaSectionsModel.swift
//  PersonalArea
//
//  Created by alvola on 11/11/2019.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public struct PersonalDataInfo {
    public var mainAddress: String?
    public var correspondenceAddress: String?
    public var phone: String?
    public var smsPhone: String?
    public var email: String?
    public var emailAlternative: String?
    
    public var correspondenceAddressMode: UserDataEditableMode = .none
    public var phoneMode: UserDataEditableMode = .none
    public var emailMode: UserDataEditableMode = .none
    
    public init() {}
}

public protocol PersonalDataModifier {
    func buildPersonalData(with personalInfo: PersonalInfoWrapper?) -> PersonalDataInfo?
}

public enum PersonalAreaAction {
    case notificationPermission
    case touchFaceId
    case geolocalization
    case alias
    case editText
}

public enum PersonalAreaSection: Equatable {
    case main
    case userData
    case digitalProfile
    case security
    case configuration
    case documentation
    case languageSelection
    case fontSize
    case photoTheme
    case alertsConfiguration
    case appPermissions
    case appInfo
    case changePassword
    case signature
    case operativeUser
    case pgPersonalization
    case secureDevice
    case editPhone
    case editEmail
    case editGDPR
    case undefined
    case recovery
    case editDNI
    case editAddress
    case quickerBalance
    case password
    case changePIN
    case wayCommunication
    case cookiesSettings
    case dataPrivacy
    case customSection(String)
    
    func cellsDictionaryWith(_ userPref: UserPrefWrapper?, resolver: DependenciesResolver? = nil) -> [CellInfo]? {
        switch self {
        case .main:
            return mainSectionCells(userPref)
        case .configuration:
            return configurationSectionCells(userPref, resolver)
        case .security:
            return securitySectionCells(userPref, resolver)
        case .userData:
            return userDataSectionCells(userPref, resolver)
        default:
            return nil
        }
    }
    
    func mainSectionCells(_ userPref: UserPrefWrapper?) -> [CellInfo]? {
        let pgCustomizationSubsection = SubsectionInfo(
            iconName: "icnCustom",
            title: localized("personalArea_button_GlobalPositionCustomization"),
            iconAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnCustomize,
            titleAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.btnPersonalAreaGPCustomization,
            arrowAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnArrowThinRight,
            goToSection: .pgPersonalization
        )
        var infoCell: [CellInfo] = []
        if userPref?.isEnabledDigitalProfileView == true {
            infoCell.append(CellInfo(
                                cellClass: "DigitalProfileTableViewCell",
                                info: DigitalProfileModel(percentage: userPref?.digitalProfilePercentage ?? 0,
                                                          type: userPref?.digitalProfileType ?? DigitalProfileEnum.cadet,
                                                          titleAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelDigitalProfile,
                                                          badgeIconAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.parsonalAreaDigitalProfileMedal,
                                                          progressBarAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.progressBarDigitalProfile,
                                                          progressPercentageAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.progressPercentageDigitalProfile,
                                                          descriptionAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelSuperDigitalProfile),
                                goToSection: .digitalProfile)
            )
        }
        infoCell.append(CellInfo(cellClass: "GeneralSectionTableViewCell",
                                 info: GeneralSectionModel(title: localized("personalArea_label_setting"),
                                                           description: localized("personalArea_text_setUpApp"),
                                                           icon: "icnSettingBlue",
                                                           titleAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelSetting,
                                                           descriptionAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelSetUpApp,
                                                           iconAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnSettingRed,
                                                           arrowAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnArrowRightSettings,
                                                           subsection: pgCustomizationSubsection),
                                 goToSection: .configuration))
        if userPref?.isPersonalAreaSecuritySettingEnabled == true {
            infoCell.append(CellInfo(cellClass: "GeneralSectionTableViewCell",
                                     info: GeneralSectionModel(title: localized("personalArea_label_security"),
                                                               description: localized("personalArea_text_security"),
                                                               icon: "icnSecurityBlue",
                                                               titleAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelSecurity,
                                                               descriptionAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelTextSecurity,
                                                               iconAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnSecurity,
                                                               arrowAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnArrowRightSecurity),
                                     goToSection: .security))
        }
        if userPref?.isPersonalDocOfferEnabled == true {
            infoCell.append(CellInfo(cellClass: "GeneralSectionTableViewCell",
                                     info: GeneralSectionModel(title: localized("personalArea_label_documentation"),
                                                               description: localized("personalArea_text_allDocuments"),
                                                               icon: "icnDocumentBlue",
                                                               titleAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelDocumentation,
                                                               descriptionAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelTextAllDocuments,
                                                               iconAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnDocumentation,
                                                               arrowAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnArrowRightDocumentation),
                                     goToSection: .documentation))
        }
        if userPref?.isRecoveryOfferEnabled == true {
            infoCell.append(CellInfo(cellClass: "GeneralSectionTableViewCell",
                                     info: GeneralSectionModel(title: localized("personalArea_label_managePayments"),
                                                               description: localized("personalArea_text_managePayments"),
                                                               icon: "icnManagePayments",
                                                               titleAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelManagePayments,
                                                               descriptionAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelTextManagePayments,
                                                               iconAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnManagePayments,
                                                               arrowAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnArrowRightManagePayments),
                                     goToSection: .recovery))
        }
        return infoCell
    }
    
    func configurationSectionCells(_ userPref: UserPrefWrapper?, _ dependenciesResolver: DependenciesResolver?) -> [CellInfo]? {
        let photo: String = localized(self.getPhotoThemeInfo(userPref, resolver: dependenciesResolver))
        let localAppConfig = dependenciesResolver?.resolve(for: LocalAppConfig.self)
        var cells = [
            CellInfo(
                cellClass: "ArrowGenericTableViewCell",
                info: GenericCellModel(titleKey: "personalArea_label_language",
                                       valueInfo: (
                                        localized(userPref?.currentLanguage?.languageName ?? "").text.capitalizedBySentence(),
                                        AccessibilityConfigurationSectionPersonalArea.languageSelected
                                       ),
                                       accessibilityIdentifier: AccessibilityConfigurationSectionPersonalArea.languageButton),
                goToSection: .languageSelection
            ),
            CellInfo(
                cellClass: "ArrowGenericTableViewCell",
                info: GenericCellModel(titleKey: "appSetting_label_displayOptions",
                                       accessibilityIdentifier: AccessibilityConfigurationSectionPersonalArea.displayOptionsButton),
                goToSection: .pgPersonalization
            ),
            CellInfo(
                cellClass: "ArrowGenericTableViewCell",
                info: GenericCellModel(titleKey: "personalArea_label_subjectPhotographic",
                                       valueInfo: (
                                        photo,
                                        AccessibilityConfigurationSectionPersonalArea.photoThemeSelected
                                       ),
                                       accessibilityIdentifier: AccessibilityConfigurationSectionPersonalArea.photoThemeButton),
                goToSection: .photoTheme
            )
        ]
        if userPref?.isConfigureAlertsEnabled == true || localAppConfig?.isEnabledConfigureAlertsInMenu == true {
            cells.append(CellInfo(
                cellClass: "ArrowGenericTableViewCell",
                info: GenericCellModel(titleKey: "personalArea_label_alert",
                                       accessibilityIdentifier: AccessibilityConfigurationSectionPersonalArea.alertConfigurationButton),
                goToSection: .alertsConfiguration
            ))
        }
        cells.append(CellInfo(
            cellClass: "ArrowGenericTableViewCell",
            info: GenericCellModel(titleKey: "personalArea_label_appPermission",
                                   accessibilityIdentifier: AccessibilityConfigurationSectionPersonalArea.permissionsButton),
            goToSection: .appPermissions
        ))
        if userPref?.isAppInfoEnabled == true {
            cells.append(CellInfo(
                cellClass: "ArrowGenericTableViewCell",
                info: GenericCellModel(titleKey: "personalArea_label_appInformation",
                                       accessibilityIdentifier: AccessibilityConfigurationSectionPersonalArea.infoButton),
                goToSection: .appInfo
            ))
        }
        return cells
    }
    
    func securitySectionCells(_ userPref: UserPrefWrapper?, _ resolver: DependenciesResolver?) -> [CellInfo]? {
        return PersonalAreaSectionsSecurityBuilder(userPref: userPref, resolver: resolver)
            .addBiometryCell()
            .addGeoCell()
            .addSecureDeviceCell()
            .addOperativeUserCell()
            .addChangePasswordCell()
            .addSignatureKeyCell()
            .addEditGDPRCell()
            .addLastAccessCell()
            .build()
    }
    
    func userDataSectionCells(_ userPref: UserPrefWrapper?, _ dependenciesResolver: DependenciesResolver?) -> [CellInfo]? {
        var cells = [CellInfo(cellClass: "UserDataEditableTableViewCell",
                              info: UserDataEditableCellModel(title: localized("personalData_label_alias"),
                                                              accessibilityTitle: "personalData_label_alias",
                                                              description: (userPref?.userAlias ?? ""),
                                                              accessibilityDescription: AccessibilityBasicInfoPersonalArea.personalDataLabelValueAlias,
                                                              accessibilityId: "areaAlias",
                                                              accessibilityBtn: AccessibilityBasicInfoPersonalArea.btnPersonalAreaEdit,
                                                              allowedCharacters: .alias,
                                                              editing: false,
                                                              editAccessibilityId: "InputBoxAlias",
                                                              mode: .local),
                              action: .alias),
                     CellInfo(cellClass: "UserDataGeneralTableViewCell",
                              info: UserDataCellModel(title: localized("personalData_label_name"),
                                                      accessibilityTitle: "personalData_label_name",
                                                      description: (userPref?.userCompleteName?.replacingOccurrences(of: "  ", with: " ") ?? "").capitalized,
                                                      accessibilityDescription: AccessibilityBasicInfoPersonalArea.personalDataLabelValueName,
                                                      accessibilityId: "areaName"))]
        if let personalAreaCells = getUserDataCells(userPref, dependenciesResolver: dependenciesResolver) {
            cells.append(contentsOf: personalAreaCells)
        }
        if userPref?.manageGDPR ?? false {
            cells.append(CellInfo(
                            cellClass: "UserDataNavigableTableViewCell",
                            info: UserDataCellModel(
                                title: localized("personalArea_label_allow"),
                                accessibilityTitle: "personalArea_label_allow",
                                description: localized("personalArea_label_dataProtection"),
                                accessibilityDescription: "personalArea_label_dataProtection",
                                accessibilityId: "areaAllow",
                                accessibilityBtn: AccessibilityBasicInfoPersonalArea.icnArrowRightDataProtection),
                            goToSection: .editGDPR))
        }
        return cells
    }
    
    func title() -> String {
        switch self {
        case .main:
            return ""
        case .digitalProfile:
            return "toolbar_title_digitalProfile"
        case .configuration:
            return "toolbar_title_setting"
        case .languageSelection:
            return "toolbar_title_language"
        case .security:
            return "toolbar_title_securityAndPrivacy"
        default:
            return ""
        }
    }
    
    func image() -> String {
        switch self {
        case .main:
            return ""
        case .configuration:
            return "icnSettingBlueBig"
        case .security:
            return "icnSecurityBlueBig"
        default:
            return ""
        }
    }
    
    func desc() -> String {
        switch self {
        case .main:
            return ""
        case .configuration:
            return "personalArea_label_setUpPermitsRequired"
        case .security:
            return "personalArea_label_setUpSecurity"
        default:
            return ""
        }
    }
}

private extension PersonalAreaSection {
    func stylizedAddress(_ address: String) -> String {
        return address.replacingOccurrences(of: ", ", with: ", ").capitalized
    }
    
    func stylizedPhone(_ phone: String) -> String {
        guard let cleanPhone = (phone.hasPrefix("34") ? phone.substring(2) : phone)?.replacingOccurrences(of: "-", with: ""),
              cleanPhone.count == 9 else { return phone }
        
        let mask = "XXX XX XX XX"
        var index = cleanPhone.startIndex
        
        return String(mask.compactMap {
            guard index < cleanPhone.endIndex else { return nil }
            if $0 == "X" {
                let idxCpy = index
                index = cleanPhone.index(after: index)
                return cleanPhone[idxCpy]
            }
            return $0
        })
    }
    
    func titleFromDocumentType(_ doc: String) -> String? {
        switch doc {
        case "N":
            return "personalData_label_nif"
        case "S":
            return "personalData_label_nif"
        case "C":
            return "personalData_label_nif"
        case "I":
            return "personalData_label_nif"
        case "U":
            return "personalData_label_nif"
        default:
            return "personalData_label_nif"
        }
    }
    
    func getUserDataCells(_ userPref: UserPrefWrapper?, dependenciesResolver: DependenciesResolver?) -> [CellInfo]? {
        guard userPref?.isPersonalAreaEnabled == true else { return nil }
        var cells = [CellInfo]()
        let modifier = dependenciesResolver?.resolve(forOptionalType: PersonalDataModifier.self)
        let personalInfoData = modifier?.buildPersonalData(with: userPref?.personalInfo)
        let localAppConfig = dependenciesResolver?.resolve(for: LocalAppConfig.self)
        if let mainAddress = personalInfoData?.mainAddress ?? userPref?.personalInfo?.maskedAddress, !mainAddress.isEmpty {
            cells.append(CellInfo(
                            cellClass: "UserDataGeneralTableViewCell",
                            info: UserDataCellModel(
                                title: localized("personalData_label_address"),
                                accessibilityTitle: "personalData_label_address",
                                description: stylizedAddress(mainAddress),
                                accessibilityDescription: AccessibilityBasicInfoPersonalArea.personalDataLabelValueAddress,
                                accessibilityId: "areaAddress"))
            )
        }
        if localAppConfig?.isEnabledPersonalData == true {
            if let correspondenceAddress = personalInfoData?.correspondenceAddress ?? userPref?.personalInfo?.correspondenceAddress, !correspondenceAddress.isEmpty {
                let mode = personalInfoData?.correspondenceAddressMode ?? ((userPref?.editPersonalInfoEnabled ?? false) ? .web : .none)
                cells.append(
                    CellInfo(
                        cellClass: "UserDataEditableTableViewCell",
                        info: UserDataEditableCellModel(
                            title: localized("personalData_label_CorrespondenceAddress"),
                            accessibilityTitle: "personalData_label_CorrespondenceAddress",
                            description: stylizedAddress(correspondenceAddress.localizedCapitalized),
                            accessibilityId: "areaCorrespondenceAddress",
                            allowedCharacters: nil,
                            editing: false,
                            editAccessibilityId: "",
                            mode: mode),
                        goToSection: (userPref?.editPersonalInfoEnabled ?? false || userPref?.isPersonalAreaEnabled ?? false) ? .editAddress : nil))
            }
        }
        if let title = titleFromDocumentType(userPref?.personalInfo?.kindOfDocument ?? ""),
           let document = userPref?.personalInfo?.maskedDocument, !document.isEmpty {
            cells.append(
                CellInfo(
                    cellClass: "UserDataEditableTableViewCell",
                    info: UserDataEditableCellModel(
                        title: localized(title),
                        accessibilityTitle: title,
                        description: document,
                        accessibilityDescription: AccessibilityBasicInfoPersonalArea.personalDataLabelValueNif,
                        accessibilityId: "areaDocument",
                        accessibilityBtn: AccessibilityBasicInfoPersonalArea.icnArrowRightNif,
                        editing: false,
                        editAccessibilityId: "",
                        mode: (userPref?.editDNIEnabled ?? false) ? .web : .none),
                    goToSection: (userPref?.editDNIEnabled ?? false) ? .editDNI : nil)
            )
        }
        if let birthday = userPref?.personalInfo?.birthday, !birthday.isEmpty {
            cells.append(
                CellInfo(
                    cellClass: "UserDataGeneralTableViewCell",
                    info: UserDataCellModel(
                        title: localized("personalData_label_birthDate"),
                        accessibilityTitle: "personalData_label_birthDate",
                        description: birthday,
                        accessibilityDescription: AccessibilityBasicInfoPersonalArea.personalDataLabelValueBirthDate,
                        accessibilityId: "areaBirthDate"))
            )
        }
        if let phone = personalInfoData?.phone ?? userPref?.personalInfo?.maskedPhone, !phone.isEmpty {
            let mode = personalInfoData?.phoneMode ?? ((userPref?.editPersonalInfoEnabled ?? false) ? .web : .none)
            cells.append(
                CellInfo(
                    cellClass: "UserDataEditableTableViewCell",
                    info: UserDataEditableCellModel(
                        title: localized("personalData_label_telf"),
                        accessibilityTitle: "personalData_label_telf",
                        description: stylizedPhone(phone),
                        accessibilityDescription: AccessibilityBasicInfoPersonalArea.personalDataLabelValueTelf,
                        accessibilityId: "areaPhone",
                        accessibilityBtn: AccessibilityBasicInfoPersonalArea.icnArrowRightTlf,
                        allowedCharacters: nil,
                        editing: false,
                        editAccessibilityId: "",
                        mode: mode),
                    goToSection: (userPref?.editPersonalInfoEnabled ?? false || userPref?.isPersonalAreaEnabled ?? false) ? .editPhone : nil))
        }
        if localAppConfig?.isEnabledPersonalData == true {
            if let smsPhone = personalInfoData?.smsPhone ?? userPref?.personalInfo?.maskPhoneSMS, !smsPhone.isEmpty {
                cells.append(
                    CellInfo(
                        cellClass: "UserDataEditableTableViewCell",
                        info: UserDataEditableCellModel(
                            title: localized("personalData_label_telfSMSAuth"),
                            accessibilityTitle: "personalData_label_telfSMSAuth",
                            description: stylizedPhone(smsPhone),
                            accessibilityDescription: nil,
                            accessibilityId: "areaPhoneSMS",
                            allowedCharacters: nil,
                            editing: false,
                            editAccessibilityId: "",
                            mode: (userPref?.editPersonalInfoEnabled ?? false) ? .web : .none),
                        goToSection: (userPref?.editPersonalInfoEnabled ?? false) ? .editPhone : nil))
            }
        }
        let email = (personalInfoData?.email ?? userPref?.personalInfo?.maskedEmail) ?? ""
        let emailAlternative = personalInfoData?.emailAlternative ?? ""
        if !email.isEmpty || !emailAlternative.isEmpty {
            let mode = personalInfoData?.emailMode ?? ((userPref?.editPersonalInfoEnabled ?? false) ? .web : .none)
            cells.append(
                CellInfo(
                    cellClass: "UserDataEditableTableViewCell",
                    info: UserDataEditableCellModel(
                        title: localized("personalData_label_mail"),
                        accessibilityTitle: "personalData_label_mail",
                        description: email.isEmpty ? emailAlternative : email.lowercased(),
                        accessibilityDescription: AccessibilityBasicInfoPersonalArea.personalDataLabelValueMail,
                        accessibilityId: "areaEmail",
                        accessibilityBtn: AccessibilityBasicInfoPersonalArea.icnArrowRightMail,
                        editing: false,
                        editAccessibilityId: "",
                        mode: mode),
                    goToSection: (userPref?.editPersonalInfoEnabled ?? false || userPref?.isPersonalAreaEnabled ?? false) ? .editEmail : nil)
            )
        }
        return cells
    }
    
    func getPhotoThemeInfo(_ userPref: UserPrefWrapper?, resolver: DependenciesResolver?) -> String {
        guard let currentPhotoThemeId = userPref?.currentPhotoTheme else {
            return PhotoThemeOptionEntity(rawValue: -1)?.titleKey() ?? ""
        }
        guard let titleKey = PhotoThemeOptionEntity(rawValue: currentPhotoThemeId)?.titleKey() else {
            let additionalPhotoThemeModifier: PhotoThemeModifierProtocol? = resolver?.resolve(forOptionalType: PhotoThemeModifierProtocol.self)
            return additionalPhotoThemeModifier?.getPhotoThemeInfo(for: currentPhotoThemeId)?.titleKey ?? ""
        }
        return titleKey
    }
}
