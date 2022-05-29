import CoreFoundationLib

class SpainAppConfig: LocalAppConfig {
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
    let isEnabledInbox = true
    let isEnabledTimeline = true
    let isEnabledPregranted = true
    let languageList: [LanguageType] = [.spanish, .catala, .galician, .euskera, .english, .french, .italian, .portuguese, .polish]
    let enablePGCardActivation = true
    let isEnabledDepositWebView = false
    let isEnabledfundWebView = false
    let clickablePension = true
    let clickableInsuranceSaving = true
    let clickableStockAccount = true
    let clickableLoan = true
    let isEnabledGoToManager: Bool = true
    let isEnabledGoToATMLocator: Bool = true
    let isEnabledGoToHelpCenter: Bool = true
    let isEnabledDigitalProfileView: Bool = true
    let isEnabledPersonalInformation: Bool = true
    let isEnabledWorld123: Bool = false
    let isEnabledSendMoney: Bool = true
    let isEnabledBills: Bool = true
    let enablePortfoliosHome: Bool = true
    let enablePensionsHome: Bool = true
    let enableInsuranceSavingHome: Bool = true
    let enabledChangeAliasProducts: [ProductTypeEntity] = [.card, .account]
    let isEnabledSecurityArea: Bool = true
    let isEnabledAnalysisArea: Bool = true
    let isEnabledWithholdings: Bool = true
    let isEnabledCardDetail = true
    let isEnabledHistorical: Bool = true
    let isEnabledFavorites: Bool = true
}
