import Foundation

public struct DomainConstant {

    public static let appConfigActive = "active"
    public static let appConfigActiveMessage = "inactiveMessage"
    public static let appConfigCounterValueEnabled  = "enabledCounterValue"
    public static let appConfigMixedUserIdCampaign = "mixedUserIdCampaign"

    // MARK: - Accounts
    public static let appConfigEnableAccountTransactionsPdf = "enableAccountTransactionsPdf"

    // MARK: - Cards
    public static let appConfigCardPayLater = "enablePayLater"
    public static let appConfigCardDirectMoney = "enableDirectMoney"
    public static let appConfigEnableCardSuperSpeed = "enableCardSuperSpeed"

    // MARK: - Support Phones
    public static let appConfigSignatureSupportPhone = "signatureSupportPhone"
    public static let appConfigOTPSupportPhone = "otpSupportPhone"
    public static let appConfigCesSupportPhone = "cesSupportPhone"
    public static let appConfigloanAmortizationSupportPhone = "loanAmortizationSupportPhone"
    public static let appConfigConsultiveUserSupportPhone = "consultiveUserSupportPhone"

    // MARK: - Plans
    public static let appConfigPensionOperationsEnabled = "enabledPensionOperations"

    // MARK: - Loans
    public static let appConfigLoanOperationsEnabled = "enabledLoanOperations" // TODO: Remove when Loan detail dissappears
    public static let appConfigEnableChangeLoanLinkedAccount = "enableChangeLoanLinkedAccount"
    public static let appConfigEnableLoanRepayment = "enableLoanRepayment"

    // MARK: - Insurances
    public static let appConfigInsuranceDetailEnabled = "enabledInsuranceDetail"
    public static let appConfigInsuranceBalanceEnabled = "enableSavingInsuranceBalance"
    public static let appConfigInsurancePASS2 = "insurancePASS2"

    // MARK: - Funds
    public static let appConfigFundOperationsSubcriptionNativeMode = "fundOperationsSubcriptionNativeMode"
    public static let appConfigFundOperationsTransferNativeMode = "fundOperationsTransferNativeMode"
    public static let appConfigBlockFundOffices = "blockFundOffices"

    // MARK: - 123 World
    public static let appConfigPapisCodes = "papisCodes"

    // MARK: - Money Plan
    public static let appConfigMoneyPlanEnabled = "enabledMoneyPlanPromotion"
    public static let appConfigMoneyNativeMode = "moneyPlanNativeMode"

    // MARK: - Personal Area
    public static let appConfigManagerSantanderPersonal = "managersSantanderPersonal"
    public static let appConfigEnableChat = "enableChatInbenta"
    public static let appConfigEnableVirtualAssistant = "enableVirtualAssistant"
    public static let appConfigEnableManagerVideoCall = "enableManagerVideoCall"
    public static let appConfigManagerVideoCallSubtitle = "managerVideoCallSubtitle"
    public static let appConfigManagerSantanderBanker = "managersBankers"

    // MARK: - Inbenta
    public static let appConfigInbentaChatUrl = "inbentaChatUrl"
    public static let appConfigInbentaChatCloseUrl = "inbentaChatCloseUrl"
    public static let appConfigEnableManagerWall = "enableManagerWall"
    public static let appConfigManagerWallUrl = "managerWallUrl"
    public static let appConfigManagerWallCloseUrl = "managerWallCloseUrl"
    public static let appConfigVirtualAssistantUrl =  "virtualAssistantUrl"
    public static let appConfigVirtualAssistantCloseUrl = "virtualAssistantCloseUrl"

    // MARK: - Mifid
    public static let enableMifid2 = "enableMifid2"
    public static let enableMifidAdvices = "enableMifidAdvices"
    public static let enableMifid1 = "enableMifid1"
    public static let mifid2NoTestMessage = "mifid2NoTestMessage"
    public static let mifid2NoClasificationMessage = "mifid2NoClasificationMessage"
    public static let mifid2NoTestNoClassificationMessage = "mifid2NoTestNoClassificationMessage"

    public static let appConfigIsInternationalUsualsActives = "isInternationalUsualsActive"
    public static let appConfigAccountCreditCardLiquidations = "accountCreditCardLiquidations"

    // MARK: - Marketplace
    public static let appConfigIsMarketplaceEnabled = "enableMarketplace"
    public static let appConfigMarketplaceUrl = "marketplaceUrl"
    public static let appConfigMarketplaceCloseUrl = "marketplaceCloseUrl"
    
    // MARK: - Bills and Taxes in Menu
    public static let appConfigIsEnabledBillsAndTaxesInMenu = "enabledBillsAndTaxesInMenu"
    
    // MARK: - Explore Products in Menu
    public static let appConfigIsEnabledExploreProductsInMenu = "enabledExploreProductsInMenu"
    
    // MARK: - Santander Apps
    public static let appConfigSantanderAppsRetailUrl = "ecosystemRetailUrl"
    public static let appConfigSantanderAppsPBUrl = "ecosystemPbUrl"

    // MARK: - Transfers
    public static let appConfigInstantNationalTransfersMaxAmount = "instantNationalTransfersMaxAmount"
    public static let appConfigIsEnabledUrgentNationalTransfersError5304 = "urgentNationalTransfersEnable5304"
    public static let appConfigUrgentNationalTransfersError5304Text = "urgentNationalTransfers5304Text"
    public static let maxLengthTransferConcept = 140
    public static var scheduledTransferMinimumDate: Date {
        let components = DateComponents(day: 2)
        return Calendar.current.date(byAdding: components, to: Date()) ?? Date()
    }
    public static var periodicTransferMinimumDate: Date {
        let components = DateComponents(day: 2)
        return Calendar.current.date(byAdding: components, to: Date()) ?? Date()
    }
    public static let appConfigEmittedTransfersMaxPagination = "emittedTransfersMaxPagination"
    public static let appConfigEmittedTransfersSearchMonths = "emittedTransfersSearchMonths"
    
    public static let appConfigEnabledFavouritesCarrusel = "enabledCarruselFavoritosDestinatario"
    
    // MARK: - Push Notifications
    public static let appConfigEnableOnlineMessagesInbox = "enableOnlineMessagesInbox"
    public static let appConfigonlineMessagesInboxUrl = "onlineMessagesInboxUrl"

    // MARK: - Registration URLs
    public static let appConfigBecomeClientUrl = "becomeClientUrl"
    public static let appConfigObtainKeysUrl = "obtainKeysUrl"
    public static let appConfigRecoverProcessUrl = "recoverProcessUrl"
    public static let appConfigRecoverKeysUrl = "recoverKeysUrl"

    // MARK: - Keychain
    public static let touchIdAccountIdentifier = "touchIdData"
    public static let biometryEvaluationSecurityAccountIdentifier = "biometryEvaluationSecurityAccount"
    public static let widgetAccountIdentifier = "isWidgetEnabled"
    public static var oldAccountIdentifier = "retail"
    public static let tokenPushIdentifier = "tokenPushData"

    // MARK: - SO:FIA
    public static var appConfigEnableBroker = "enableBroker"

    // MARK: - Account easy pay
    public static var appConfigAccountEasyPayLowAmountLimit = "accountEasyPayLowAmountLimit"
    public static var appConfigAccountEasyPayMinAmount = "accountEasyPayMinAmount"
    public static var appConfigEnableAccountEasyPayForBills = "enableAccountEasyPayForBills"
    public static var appConfigEnableAccountEasyPayForStandardNationalTransfers = "enableAccountEasyPayForStandardNationalTransfers"

    // MARK: - Stocks
    public static var appConfigStocksNativeMode = "stocksNativeMode"
    
    // MARK: - Bill & Taxes

    public static var appConfigEnabledReceiptDuplicated = "enableReceiptDuplicated"
    public static var appConfigEnabledReceiptPdf = "enableReceiptPdf"
    public static var appConfigEnabledReceiptReturn = "enableReceiptReturn"
    public static var appConfigEnabledReceiptCanceled = "enableReceiptCanceled"
    public static var appConfigEnabledReceiptSettleAnotherAccount = "enableReceiptSettleAnotherAccount"
    public static var appConfigEnabledReceiptMasiveDomicile = "enableReceiptMasiveDomicile"
    public static var appConfigEnablePdfForReceipts = "enablePdfForReceipts"

    // MARK: - OTP Push
    public static var appConfigEnableOtpPush = "enableOtpPush"
    public static var appConfigMessageOtpPushBeta = "messageOtpPushBeta"

    // MARK: - Manager
    public static var appConfigManagerWallVersion = "managerWallVersion"
    public static let appConfigManagerOTPServices = "otpServiceNames"
    public static let appConfigManagerSideMenuCoachmark = "enableManagerMenu"
    public static let appConfigManagerSidebarManagerNotifications = "enableSidebarManagerNotifications"
    public static let appConfigManagerMulMovUrls = "mulMovUrls"

    // MARK: - Key for secureString
    public static var K0 = "bYcSFm9xTI"
    public static var K1 = "7UivhPBTE7"
    public static var K2 = "9NmnoEgb31oU"
    
     // MARK: - SCA
    public static var appConfigCheckSca = "enableSCALogin"
    public static var appConfigEnableSCAAccountTransactions = "enableSCAAccountTransactions"
    
    // MARK: - Negative credit card balance
    public static var appConfigIsNegativeCreditBalanceCardSuperSpeed = "isNegativeCreditBalanceCardSuperSpeed"
    
    // MARK: - Menu
    public static var appConfigHighlightMenu = "highlightMenu"
    public static var appConfigLogoutOffersRandom = "logoutOffersRandom"
    
    // MARK: - Is Sanflix Enabled
    public static var appConfigEnableApplyBySanflix = "enableApplyBySanflix"
    
    // MARK: - Loans Simulator
    public static let appConfigSimulationfamilyCode = "simulationfamilyCode"
    public static let appConfigSimulationcampaignsCode = "simulationcampaignsCode"
    
    // MARK: - Onboarding
    public static let appConfigDisableOnboarding = "disableOnboarding"
    public static let appConfigOnboardingVersion = "onboardingVersion"
    
    // MARK: - Analysis zone
    public static let appConfigAnalysisEnabled = "enabledAnalysisZone"
    
    // MARK: - My products
    public static let appConfigMyProducts = "sidebarProductsTitle"
    
    // MARK: - Timeline
    public static let appConfigTimelineEnabled = "enableTimeLine"

    // MARK: - Public Product
    public static let enablePublicProducts = "enablePublicProducts"
    
    // MARK: - Trusteer
    public static let enabledTrusteer = "enableTrusteer"
    public static let enabledTrusteerTransfers = "enableTrusteerTransfers"
    public static let enabledTrusteerTransfersNoSepa = "enableTrusteerTransfersNoSEPA"
    public static let enableTrusteerTransfersDeferred = "enableTrusteerTransfersDeferred"

    // MARK: - What's New Bubble
    public static let enabledWhatsNew = "enabledWhatsNew"
    
    // MARK: - Force Update Password
    public static let forceUpdateKeys = "forceUpdateKeys"
    
    // MARK: - Coming Features
    public static let appConfigEnableComingFeatures = "enableComingFeatures"
    
    // MARK: - Financing Zone
    public static let appConfigEnableFinancingZone = "enableFinancingZone"
    
    // MARK: - Stockholders
    public static let appConfigEnableStockholders = "enableStockholders"
}
