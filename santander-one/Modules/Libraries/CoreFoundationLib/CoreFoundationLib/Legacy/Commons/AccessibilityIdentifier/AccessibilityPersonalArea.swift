//
//  AccessibilityPersonalArea.swift
//  Commons
//
//  Created by David Gálvez Alonso on 01/04/2020.
//

public enum AccessibilityPersonalArea {
    // General budget
    public static let btnSave = "btnSave"
    public static let inputImportBudget = "inputImportBudget"
    public static let budgetSlider = "budgetSlider"
    public static let maximumLabel = "maximumLabel"
    public static let titleLabel = "titleLabel"
    public static let minimumLabel = "minimumLabel"
}

public enum AccessibilityConfigurationSectionPersonalArea {
    public static let languageButton = "configurationSectionBtnLanguage"
    public static let languageSelected = "configurationSectionLabelSelectedLanguage"
    public static let displayOptionsButton = "configurationSectionBtnDisplayOptions"
    public static let photoThemeButton = "configurationSectionBtnPhotoTheme"
    public static let photoThemeSelected = "configurationSectionLabelSelectedPhotoTheme"
    public static let alertConfigurationButton = "configurationSectionBtnAlertConfiguration"
    public static let permissionsButton = "configurationSectionBtnPermissions"
    public static let infoButton = "configurationSectionBtnInfo"
    public static let quickBalanceIcnInfo = "quickBalanceIcnInfo"
}

public enum AccessibilityOperabilitySelector {
    public static let personalAreaLabelAdvisory = "personalArea_label_advisory"
    public static let tooltipTextPersonalAreaUser = "tooltip_text_personalAreaUser"
    public static let personalAreaLabelOperative = "personalArea_label_operative"
    public static let operabilityTextOperator = "operability_text_operator"
    public static let operabilityTextAdvisory = "operability_text_advisory"
    public static let operabilitySelectorBtnContinue = "operabilitySelectorBtnContinue"
    public static let icnOperativeSelected = "icnOperativeSelected"
    public static let icnOperativeUnselected = "icnOperativeUnselected"
    public static let icnAdvisorySelected = "icnAdvisorySelected"
    public static let icnAdvisoryUnselected = "icnAdvisoryUnselected"
    public static let personalAreaLabelUserSelected = "personalArea_label_user_selected"
}

public enum AccessibilityLastAccessCell {
    public static let personalAreaBtnLastAccess = "personalAreaBtnLastAccess"
    public static let personalAreaLabelLastAccessDate = "personalAreaLabelLastAccessDate"
    public static let personalAreaLabelLastAccess = "personalArea_button_lastAccess"
}

public enum AccessibilitySecureDeviceAlias {
    public static let otpPushLabelRegisteredDevice = "otpPush_label_registeredDevice"
    public static let otpPushLabelTitleRegisteredDevice = "otpPush_label_titleRegisteredDevice"
    public static let summaryItemTerminalInfo = "summary_item_terminal"
    public static let summaryItemAliasInfo = "summary_item_alias"
    public static let summaryItemRegistrationDateInfo = "summary_item_registrationDate"
    public static let summaryItemTerminal = "summaryItemTerminal"
    public static let summaryItemAlias = "summaryItemAlias"
    public static let summaryItemRegistrationDate = "summaryItemRegistrationDate"
    public static let otpPushButtomUpdateSecureDevice = "otpPush_buttom_updateSecureDevice"
    public static let secureDeviceBtnUpdateSecurityDevice = "secureDeviceBtnUpdateSecurityDevice"
}

public enum AccessibilityChangePassword {
    public static let keyChangeTextAbout = "keyChange_text_about"
    public static let keyChangeTextAboutBox = "keyChange_text_about_box"
    public static let securityBtnSaveChanges = "securityBtnSaveChanges"
    public static let personalAreaLabelSigningChange = "personal_area_label_signingChange"
}

public enum AccessibilityActivateAndChange {
    public static let signingTitlleAbout = "signing_titlle_about"
    public static let signingTextAbout = "signing_text_about"
    public static let signingInputNewKey = "signing_input_newKey"
    public static let changeSignViewInputSigningNew = "changeSignViewInputSigningNew"
    public static let signingInputRepeatKey = "signing_input_repeatKey"
    public static let changeSignViewInputRepeatSigningNew = "changeSignViewInputRepeatSigningNew"
    public static let changeSignBtnContinue = "changeSignBtnContinue"
}

public enum AccessibilitySecuritySectionPersonalArea {
    public static let securitySectionViewHeader = "securitySectionViewHeader"
    public static let icnSecurityRedBig = "icnSecurityRedBig"
    public static let icnArrowRight = "icnArrowRight"
    public static let securitySectionBtnBiometry = "securitySectionBtnBiometry"
    public static let securitySectionViewBiometrySwitch = "securitySectionViewBiometrySwitch"
    public static let securitySectionBtnGeolocation = "securitySectionBtnGeolocation"
    public static let securitySectionViewGeolocationSwitch = "securitySectionViewGeolocationSwitch"
    public static let securitySectionBtnSecureDevice = "securitySectionBtnSecureDevice"
    public static let securitySectionBtnUser = "securitySectionBtnUser"
    public static let securitySectionLabelSelectedUser = "securitySectionLabelSelectedUser"
    public static let securitySectionBtnMagicSignatureKey = "securitySectionBtnMagicSignatureKey"
    public static let securitySectionBtnSignatureKey = "securitySectionBtnSignatureKey"
    public static let securitySectionBtnPrivacy = "securitySectionBtnPrivacy"
    public static let securitySectionBtnChangePIN = "securitySectionBtnChangePIN"
    public static let securitySectionBtnWayCommunication = "securitySectionBtnWayCommunication"
    public static let securitySectionBtnCookiesSettings = "securitySectionBtnCookiesSettings"
    public static let securitySectionBtnTooltip = "securitySectionBtnTooltip"
    public static let securitySectionLabelTooltip = "security_section_label_tooltip"
    public static let securitySectionBtnOperativeTooltip = "securitySectionBtnOperativeTooltip"
    public static let securitySectionBtnQuickerBalance = "securitySectionBtnQuickerBalance"
    public static let securitySectionLabelQuickerBalance = "security_section_label_quickerBalance"
}

public enum AccesibilityHelpCenterPersonalArea: String {
    case helpCenterBtnHelpCall
    case helpCenterBtnHelpCallFlipped
    case helpCenterBtnPlanOne
    case helpCenterBtnPlanOneFlipped
    case helpCenterBtnPermanentAttention
    case helpCenterBtnPermanentAttentionFlipped
    case helpCenterBtnHelpChat
    case helpCenterBtnHelpWhatsapp
    case helpCenterBtnOfficeOffer
    case helpCenterBtnStolenCard
    case helpCenterBtnStolenCardFlipped
    case imgOfferAtt
    case helpCenterHeaderFaqs
    case helpCenterTitleVirtualAssistant = "helpCenter_title_virtualAssistant"
    case helpCenterInputVirtualAssistant
    case supportTitleHelpYou = "support_title_helpYou"
    case helpCenterLabelWanted = "helpCenter_label_wanted"
    case helpCenterListFaqs
    case btnStolenCard
    case btnReportFraud
    case btnKeyLock
    case btnPin
    case btnCvv
    case btnNeedCash
    case btnSendMoney
    case btnCancelTransfer
    case btnChangeAccessKey
    case btnHelpCall2
    case btnHelpChat2
    case btnStolenCardFlipped
    case btnReportFraudFlipped
    case btnHelpCall2Flipedd
    case keyChangeTitleCurrentKey
    case keyChangeTextCurrentKey
    case keyChangeTextFieldTitleCurrentKey
    case keyChangeTextFieldCurrentKey
    case inputCurrentChangePasswordBtnContinue
    case keyChangeTitleNewKey
    case keyChangeTextNewKey
    case keyChangeTextFieldTitleNewKey
    case keyChangeTextFieldNewKey
    case keyChangeTitleRepeatKey
    case keyChangeTextFieldRepeatKey
    case inputNewPassChangePasswordButtonContinue
    case tipsCarousel
    case tipsBtnSeeAll
    case genericButtonSeeAll = "generic_button_seeAll"
}

public enum AccessibilityAppPermissionsPersonalArea {
    public static let headerTitle = "managementPermission_label_changePermission"
    public static let iconHeaderImage = "icnArrowPhone"
    public static let localizationTitle = "managementPermission_title_location"
    public static let localizationText = "managementPermission_text_locationPermission"
    public static let localizationSwitch = "managementPermission_switch_location"
    public static let contactsTitle = "managementPermission_title_contact"
    public static let contactsText = "managementPermission_text_readContacts"
    public static let contactsSwitch = "managementPermission_switch_contact"
    public static let photosTitle = "managementPermission_title_photos"
    public static let photosText = "managementPermission_text_photosPermission"
    public static let photosSwitch = "managementPermission_switch_photos"
    public static let cameraTitle = "managementPermission_title_camera"
    public static let cameraText = "managementPermission_text_cameraPermission"
    public static let cameraSwitch = "managementPermission_switch_camera"
    public static let notificationsTitle = "managementPermission_title_notifications"
    public static let notificationsText = "managementPermission_text_notificationsPermission"
    public static let notificationSwitch = "managementPermission_switch_notifications"
}

public enum AccesibilityConfigurationPersonalArea {
    public static let appNumberVersion = "appInformation_label_appVersion"
    public static let appLabelVersion = "appInformation_input_version"
    public static let appOsNumberVersion = "appInformation_label_osVersion"
    public static let appOsLabelVersion = "appInformation_input_osVersion"
    public static let lasUpdateNumber = "personalAreaListNewsLastUpdate"
    public static let lasUpdateLabel = "personalAreaListNewsLastUpdateDescription"
    public static let newsLastUpdate = "appInformation_label_newsLastUpdate"
    public static let changeLanguage = "personalAreaBtnLanguagebuttonChange"
    public static let updateButton = "personalAreaBtnUpdate"
    public static let icon = "icnAppSan"
}

public enum AccessibilityDigitalProfileTooltip {
    public static let btnInClose = "icnClose"
    public static let titleDigitalProfile = "digitalProfileTooltip_title_digitalProfile"
    public static let textCheckYourDigitalProfile = "digitalProfileTootip_text_checkYourDigitalProfile"
    public static let titleDoYouKnow = "digitalProfileTooltip_title_doYouKnow"
    public static let icnMedalCadet = "icnMedalCadet"
    public static let labelCadetPercentage = "digitalProfileTooltip_label_cadetPercentage"
    public static let labelCadet = "digitalProfile_label_cadet"
    public static let textCadet = "digitalProfileTooltip_text_cadet"
    public static let icnMedalAdvancedDigital = "icnMedalAdvancedDigital"
    public static let labelAdvancedPercentage = "digitalProfileTooltip_label_advancedPercentage"
    public static let labelAdvanced = "digitalProfile_label_advanced"
    public static let textAdvanced = "digitalProfileTooltip_text_advanced"
    public static let icnMedalExpert = "icnMedalExpert"
    public static let labelExpertPercentage = "digitalProfileTooltip_label_expertPercentage"
    public static let labelExpert = "digitalProfile_label_expert"
    public static let textExpert = "digitalProfileTooltip_text_expert"
    public static let icnMedalTop = "icnMedalTop"
    public static let labelTopPercentage = "digitalProfileTooltip_label_topPercentage"
    public static let labelTop = "digitalProfile_label_top"
    public static let textTop = "digitalProfileTooltip_text_top"
}

public enum AccessibilityDigitalProfilePendingCarousel {
    public static let pendingCarousel = "digitalProfile_pendingCarousel"
    public static let pendingCarouselBox = "digitalProfile_pendingCarousel_box"
}

public enum AccessibilityUserNameHeaderPersonalArea {
    public static let icnPersonalAreaBtnCamera = "personalAreaBtnIcnCamera"
    public static let icnCamera = "icnCamera"
    public static let icnArrowRight = "icnArrowRight"
    public static let personalAreaLabelUserNameData = "personalArea_label_userNameData"
    public static let personalAreaLabelAllData = "personalArea_label_allData"
}

public enum AccessibilitySettingsListPersonalArea {
    public static let personalAreaLabelDigitalProfile = "personalArea_label_digitalProfile"
    public static let parsonalAreaDigitalProfileMedal = "personalArea_image_digitalProfileMedal"
    public static let progressBarDigitalProfile = "progressBar_digitalProfile"
    public static let progressPercentageDigitalProfile = "progressPercentage_digitalProfile"
    public static let personalAreaLabelSuperDigitalProfile = "personalArea_text_superDigitalProfile"
    public static let icnSettingRed = "icnSettingRed"
    public static let personalAreaLabelSetting = "personalArea_label_setting"
    public static let personalAreaLabelSetUpApp = "personalArea_text_setUpApp"
    public static let icnArrowRightSettings = "icnArrowRight_settings"
    public static let icnCustomize = "icnCustomize"
    public static let btnPersonalAreaGPCustomization = "personalArea_button_GlobalPositionCustomization"
    public static let icnArrowThinRight = "icnArrowThinRight"
    public static let icnSecurity = "icnSecurity"
    public static let personalAreaLabelSecurity = "personalArea_label_security"
    public static let personalAreaLabelTextSecurity = "personalArea_text_security"
    public static let icnArrowRightSecurity = "icnArrowRight_security"
    public static let icnDocumentation = "icnDocumentation"
    public static let personalAreaLabelDocumentation = "personalArea_label_documentation"
    public static let personalAreaLabelTextAllDocuments = "personalArea_text_allDocuments"
    public static let icnArrowRightDocumentation = "icnArrowRight_documentation"
    public static let icnManagePayments = "icnManagePayments"
    public static let personalAreaLabelManagePayments = "personalArea_label_managePayments"
    public static let personalAreaLabelTextManagePayments = "personalArea_text_managePayments"
    public static let icnArrowRightManagePayments = "icnArrowRight_managePayments"
}

public enum AccessibilityBasicInfoPersonalArea {
    public static let icnArrowRightNif = "icn_arrowRight_nif"
    public static let icnArrowRightTlf = "icn_arrowRight_tlf"
    public static let icnArrowRightMail = "icn_arrowRight_mail"
    public static let icnArrowRightDataProtection = "icn_arrowRight_dataProtection"
    public static let icnCameraPersonalArea = "icnCamera"
    public static let btnPersonalAreaIcnCamera = "personalAreaBtnIcnCamera"
    public static let btnPersonalAreaAddPhoto = "personalAreaBtnAddPhoto"
    public static let personalDataLabelValueAlias = "personalData_label_valueAlias"
    public static let btnPersonalAreaEdit = "personalAreaBtnEdit"
    public static let personalDataLabelValueName = "personalData_label_valueName"
    public static let personalDataLabelValueAddress = "personalData_label_valueAddress"
    public static let personalDataLabelValueNif = "personalData_label_valueNif"
    public static let personalDataLabelValueBirthDate = "personalData_label_valueBirthDate"
    public static let personalDataLabelValueTelf = "personalData_label_valueTelf"
    public static let personalDataLabelValueMail = "personalData_label_valueMail"
}

public enum AccessibilityPhotoThemePersonalizationPersonalArea {
    public static let saveThemeChangesButton = "photoTheme_button_saveChanges"
}

public enum AccessibilityPGPersonalizationPersonalArea {
    public static let generalViewCollectionTitle = "pgPersonalization_label_carouselTitle"
    public static let saveChangesButton = "pgPersonalization_saveChanges_Button"
    public static let generalViewCollectionView = "pgPersonalization_view_collectionView"
    public static let generalViewPageControl = "pgPersonalization_view_pageControl"
    public static let generalViewLabel = "pgPersonalization_label_slideTitleLabel"
    public static let generalViewLabelLabel = "pgPersonalization_label_slideDescriptionLabel"
    public static let themeColorSelectorRedBtn = "themeColorSelectorView_button_red"
    public static let themeColorSelectorGreyBtn = "themeColorSelectorView_button_gray"
    public static let discreteModeTitle = "displayOptions_title_seeOrder"
    public static let discreteModeSubTitle = "pgCustomize_label_discreetModule"
    public static let discreteModeDescription = "pgCustomize_text_discreetModule"
    public static let discreteModeSwitchLabel = "pgCustomize_text_activateDiscreetModule"
    public static let discreteModeSwitch = "discreteMode_switch_discrete"
    public static let discreteModeOfferImage = "imgVideo"
    public static let discreteModePlayImage = "icnPlay"
    public static let discreteModeOfferView = "discreteMode_view_image"
    public static let financingChartsTitle = "displayOptions_title_initialModules"
    public static let financingSwitch = "pgCustomize_switch_financing"
    public static let financingChartsTitleExpense = "pgCustomize_label_generalBudget"
    public static let financingChartsExpenseLabel = "financingCharts_label_expense"
    public static let financingChartsSwitchLabel = "pgCustomize_text_yourExpensesAndFinance"
    public static let financingChartsArrowImage = "pgCustomize_financingCharts_arrowRight"
    public static let frequentOperationsTitle = "personalArea_label_frequentOperative"
    public static let frequentOperationsArrow = "pgCustomize_label_directAccess"
    public static let frequentOperationsArrowImage = "pgCustomize_frequentOperations_arrowRight"
    public static let frequentOperationOperativeView = "imgFrequentOperative"
    public static let productsViewTitle = "pgCustomize_label_products"
    public static let productsViewSubTitle = "displayOptions_text_seeOrder"
    public static let productsViewArrow = "pgCustomize_label_orderAndChange"
    public static let productOrderArrowImage = "pgCustomize_productOrder_arrowRight"
    public static let productsViewOrderView = "imgOrderOption"
    public static let slideTitleLabel = "baseSelectionName"
    public static let slideDescriptionLabel = "baseSelectionDesc"

}
