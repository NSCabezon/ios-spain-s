//
//  LocalAppConfigMock.swift
//  CoreTestData
//
//  Created by alvola on 11/5/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

public final class LocalAppConfigMock: LocalAppConfig {
    public var isEnabledConsentManagement: Bool = false
    public var isEnabledPersonalData: Bool = true
    public var isEnabledTopUpsPrivateMenu: Bool = false
    public var isEnabledMailbox: Bool = false
    public var isEnabledConfigureAlertsInMenu: Bool = false
    public var isEnabledNotificationsInMenu: Bool = false
    public var isScheduledTransferDetailDeleteButtonEnabled: Bool = true
    public var isScheduledTransferDetailEditButtonEnabled: Bool = true
    public var countryCode: String = "ES"
    public var isTransferDetailPDFButtonEnabled: Bool = true
    public var isTransferDetailReuseButtonEnabled: Bool = true
    public var isEnabledForceTouch: Bool = false
    public var digitalProfile: Bool = true
    public var language: LanguageType = .spanish
    public var endMorning: Int = 0
    public var endAfternoon: Int = 0
    public var endNight: Int = 0
    public var enableBiometric: Bool = false
    public var isEnabledPfm: Bool = false
    public var privateMenu: Bool = false
    public var isPortugal: Bool = false
    public var isEnabledPlusButtonPG: Bool = false
    public var isEnabledConfigureWhatYouSee: Bool = false
    public var isEnabledMagnifyingGlass: Bool = false
    public var isEnabledInbox: Bool = false
    public var isEnabledTimeline: Bool = false
    public var isEnabledPregranted: Bool = false
    public var languageList: [LanguageType] = [.spanish, .english, .french]
    public var enablePGCardActivation: Bool = false
    public var isEnabledDepositWebView: Bool = false
    public var isEnabledfundWebView: Bool = false
    public var clickableLoan: Bool = false
    public var isEnabledGoToManager: Bool = false
    public var isEnabledGoToPersonalArea: Bool = true
    public var isEnabledGoToATMLocator: Bool = false
    public var isEnabledGoToHelpCenter: Bool = false
    public var isEnabledDigitalProfileView: Bool = true
    public var isEnabledPersonalInformation: Bool = false
    public var isEnabledWorld123: Bool = false
    public var isEnabledSendMoney: Bool = false
    public var isEnabledBills: Bool = false
    public var enablePortfoliosHome: Bool = false
    public var enablePensionsHome: Bool = false
    public var enableInsuranceSavingHome: Bool = false
    public var enabledChangeAliasProducts: [ProductTypeEntity] = []
    public var isEnabledSecurityArea: Bool = false
    public var isEnabledAnalysisArea: Bool = false
    public var isEnabledWithholdings: Bool = false
    public var isEnabledCardDetail: Bool = false
    public var isEnabledHistorical: Bool = false
    public var isEnabledFavorites: Bool = false
    public var enableSplitExpenseBizum: Bool = true
    public var isEnabledChangeDestinationCountry: Bool = false
    public var isEnabledChangeCurrency: Bool = false
    public var maxLengthInternalTransferConcept: Int = 140
    public var analysisAreaHasTimelineSection: Bool = true
    public var analysisAreaIsIncomeSelectable: Bool = true
    public var analysisAreaIsExpensesSelectable: Bool = true
    public var isAnalysisAreaHomeEnabled: Bool = true
    public var showATMIntermediateScreen: Bool = true
    public var isEnabledEditAlias: Bool = false
    public var isEnabledBillsAndTaxesInMenu: Bool = true
    public var isEnabledExploreProductsInMenu: Bool = true
    public var isEnabledPersonalAreaInMenu: Bool = true
    public var isEnabledHelpUsInMenu: Bool = true
    public var isEnabledATMsInMenu: Bool = true
    public var isEnabledOnboardingLocationDialog: Bool = false
    public var isEnabledSavings: Bool = true
    public init() {}
}
