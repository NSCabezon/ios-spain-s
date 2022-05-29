import Foundation
import CoreDomain

// Comform classes by Country
public protocol LocalAppConfig: LocalSections, LocalTime, LocalConfiguration {}

public protocol LocalTime {
    var endMorning: Int { get }
    var endAfternoon: Int { get }
    var endNight: Int { get }
}

public protocol LocalSections {
    var digitalProfile: Bool { get }
    var language: LanguageType { get }
}

public protocol LocalConfiguration {
    var enableBiometric: Bool { get }
    var isEnabledPfm: Bool { get }
    var privateMenu: Bool { get }
    var isPortugal: Bool { get }
    var isEnabledPlusButtonPG: Bool { get }
    var isEnabledConfigureWhatYouSee: Bool { get }
    var isEnabledMagnifyingGlass: Bool { get }
    var isEnabledMailbox: Bool { get }
    var isEnabledTimeline: Bool { get }
    var isEnabledPregranted: Bool { get }
    var languageList: [LanguageType] { get }
    var isEnabledDepositWebView: Bool { get }
    var isEnabledfundWebView: Bool { get }
    var clickableLoan: Bool { get }
    var isEnabledGoToManager: Bool { get }
    var isEnabledGoToPersonalArea: Bool { get }
    var showATMIntermediateScreen: Bool { get }
    var isEnabledGoToHelpCenter: Bool { get }
    var isEnabledDigitalProfileView: Bool { get }
    var isEnabledWorld123: Bool { get }
    var isEnabledSendMoney: Bool { get }
    var isEnabledBills: Bool { get }
    var isEnabledBillsAndTaxesInMenu: Bool { get }
    var isEnabledExploreProductsInMenu: Bool { get }
    var isEnabledPersonalAreaInMenu: Bool { get }
    var isEnabledConfigureAlertsInMenu: Bool { get }
    var isEnabledNotificationsInMenu: Bool { get }
    var isEnabledPersonalData: Bool { get }
    var isEnabledHelpUsInMenu: Bool { get }
    var isEnabledATMsInMenu: Bool { get }
    var enablePortfoliosHome: Bool { get }
    var enablePensionsHome: Bool { get }
    var enableInsuranceSavingHome: Bool { get }
    var enabledChangeAliasProducts: [ProductTypeEntity] { get }
    var isEnabledSecurityArea: Bool { get }
    var isEnabledAnalysisArea: Bool { get }
    var isEnabledWithholdings: Bool { get }
    var isEnabledCardDetail: Bool { get }
    var enableSplitExpenseBizum: Bool { get }
    var isEnabledHistorical: Bool { get }
    var isEnabledChangeDestinationCountry: Bool { get }
    var isEnabledChangeCurrency: Bool { get }
    var maxLengthInternalTransferConcept: Int { get }
    var analysisAreaHasTimelineSection: Bool { get }
    var analysisAreaIsIncomeSelectable: Bool { get }
    var analysisAreaIsExpensesSelectable: Bool { get }
    var isAnalysisAreaHomeEnabled: Bool { get }
    var countryCode: String { get }
    var isTransferDetailPDFButtonEnabled: Bool { get }
    var isTransferDetailReuseButtonEnabled: Bool { get }
    var isScheduledTransferDetailDeleteButtonEnabled: Bool { get }
    var isScheduledTransferDetailEditButtonEnabled: Bool { get }
    var isEnabledTopUpsPrivateMenu: Bool { get }
    var isEnabledOnboardingLocationDialog: Bool { get }
    var isEnabledConsentManagement: Bool { get }
    var isEnabledSavings: Bool { get }
}

// MARK: Default implementation
public extension LocalAppConfig {
    var isEnabledConsentManagement: Bool {
            return true
        }
}
