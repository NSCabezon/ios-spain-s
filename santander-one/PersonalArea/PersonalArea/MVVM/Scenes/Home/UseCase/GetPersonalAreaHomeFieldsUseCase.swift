//
//  GetPersonalAreaHomeFieldsUseCase.swift
//  PersonalArea
//
//  Created by alvola on 11/4/22.
//

import Foundation
import OpenCombine
import CoreFoundationLib
import CoreDomain

public protocol GetPersonalAreaHomeFieldsUseCase {
    func fetchPersonalAreaHomeFields(_ config: PersonalAreaHomeRepresentable) -> AnyPublisher<[PersonalAreaCellInfoRepresentable], Never>
}

struct DefaultGetPersonalAreaHomeFieldsUseCase: GetPersonalAreaHomeFieldsUseCase {
    func fetchPersonalAreaHomeFields(_ config: PersonalAreaHomeRepresentable) -> AnyPublisher<[PersonalAreaCellInfoRepresentable], Never> {
        return Just(fieldsWith(config: config)).eraseToAnyPublisher()
    }
}

private extension DefaultGetPersonalAreaHomeFieldsUseCase {
    func fieldsWith(config: PersonalAreaHomeRepresentable) -> [PersonalAreaCellInfoRepresentable] {
        let pgCustomizationSubsection = SubsectionInfo(
            iconName: "icnCustom",
            title: localized("personalArea_button_GlobalPositionCustomization"),
            iconAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnCustomize,
            titleAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.btnPersonalAreaGPCustomization,
            arrowAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnArrowThinRight,
            goToSection: .pgPersonalization
        )
        var infoCell: [CellInfo] = []
        if config.isEnabledDigitalProfileView {
            infoCell.append(CellInfo(
                                cellClass: "DigitalProfileTableViewCell",
                                info: DigitalProfileModel(percentage: config.digitalProfileInfo?.digitalProfilePercentage ?? 0.0,
                                                          type: config.digitalProfileInfo?.digitalProfileType ?? DigitalProfileEnum.cadet,
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
        if config.isPersonalAreaSecuritySettingEnabled {
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
        if config.isPersonalDocOfferEnabled {
            infoCell.append(CellInfo(cellClass: "GeneralSectionTableViewCell",
                                     info: GeneralSectionModel(title: localized("personalArea_label_documentation"),
                                                               description: localized("personalArea_text_allDocuments"),
                                                               icon: "icnDocumentation",
                                                               titleAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelDocumentation,
                                                               descriptionAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.personalAreaLabelTextAllDocuments,
                                                               iconAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnDocumentation,
                                                               arrowAccessibilityIdentifier: AccessibilitySettingsListPersonalArea.icnArrowRightDocumentation),
                                     goToSection: .documentation))
        }
        if config.isRecoveryOfferEnabled {
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
}
