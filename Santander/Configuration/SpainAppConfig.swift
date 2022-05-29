//
//  SpainAppConfig.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 2/2/21.
//

import CoreFoundationLib
import CoreDomain

class SpainAppConfig: LocalAppConfig {
    var isEnabledMailbox = true
    var isAnalysisAreaHomeEnabled = true
    var countryCode = "ES"
    let isScheduledTransferDetailDeleteButtonEnabled = true
    let isScheduledTransferDetailEditButtonEnabled = true
    let isEnabledGoToATMLocator = true
    let isEnabledInbox = false
    let isEnabledHistorical = true
    let isEnabledFavorites = true
    let enableBiometric = true
    let digitalProfile = true
    let endMorning = 5
    let endAfternoon = 14
    let endNight = 20
    let language: LanguageType = .spanish
    let isEnabledPfm = true
    let privateMenu = true
    let isEnabledConfigureWhatYouSee = true
    let isPortugal = false
    let isEnabledPlusButtonPG = true
    let isEnabledMagnifyingGlass = true
    let isEnabledTimeline = true
    let isEnabledPregranted = true
    let languageList: [LanguageType] = [.spanish, .catala, .galician, .euskera, .english, .french, .italian, .portuguese, .polish]
    let isEnabledDepositWebView = false
    let isEnabledfundWebView = false
    let clickablePension = true
    let clickableInsuranceSaving = true
    let clickableStockAccount = true
    let clickableLoan = true
    let isEnabledGoToManager: Bool = true
    let isEnabledGoToPersonalArea: Bool = true
    let showATMIntermediateScreen: Bool = true
    let isEnabledGoToHelpCenter: Bool = true
    let isEnabledDigitalProfileView: Bool = true
    let isEnabledWorld123: Bool = false
    let isEnabledSendMoney: Bool = true
    let isEnabledBills: Bool = true
    let isEnabledBillsAndTaxesInMenu: Bool = true
    let isEnabledExploreProductsInMenu: Bool = true
    let isEnabledPersonalAreaInMenu: Bool = true
    let isEnabledConfigureAlertsInMenu: Bool = false
    let isEnabledNotificationsInMenu: Bool = false
    let isEnabledHelpUsInMenu: Bool = true
    let isEnabledATMsInMenu: Bool = true
    let enablePortfoliosHome: Bool = true
    let enablePensionsHome: Bool = true
    let enableInsuranceSavingHome: Bool = true
    let enabledChangeAliasProducts: [ProductTypeEntity] = [.card, .account]
    let isEnabledSecurityArea: Bool = true
    let isEnabledAnalysisArea: Bool = true
    let isEnabledWithholdings: Bool = true
    let isEnabledCardDetail = true
    let enableSplitExpenseBizum: Bool = true
    let isEnabledChangeDestinationCountry: Bool = true
    let isEnabledChangeCurrency: Bool = true
    let isEnabledEditAlias = false
    let maxLengthInternalTransferConcept: Int = 140
    let analysisAreaHasTimelineSection: Bool = true
    let analysisAreaIsIncomeSelectable: Bool = true
    let analysisAreaIsExpensesSelectable: Bool = true
    let isTransferDetailPDFButtonEnabled = true
    let isTransferDetailReuseButtonEnabled = true
    let isEnabledTopUpsPrivateMenu: Bool = false
    let isEnabledPersonalData = false
    var isEnabledOnboardingLocationDialog: Bool = true
    let isEnabledSavings = false
}
