//
//  PullOffersLocationsFactoryEntity.swift
//  Models
//
//  Created by Tania Castellano Brasero on 24/10/2019.
//

import CoreDomain

public struct PullOffersLocationsFactoryEntity {
    public init() { }
    
    // MARK: - Global Position
    public var globalPosition: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgCta, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgTar, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgSav, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgVal, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgFon, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgDep, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgPla, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgPre, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgTop, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgSai, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgSpr, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgCtaNo, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgCtaBelow, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgTarNo, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgTarBelow, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgSavNo, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgSavBelow, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgValNo, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgValBelow, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgFonNo, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgFonBelow, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgDepNo, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgDepBelow, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgPlaNo, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgPlaBelow, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgPreNo, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgPreBelow, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgSaiNo, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgSaiBelow, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgSprNo, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgSprBelow, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.happyBirthday, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.loansSimulator, hasBanner: false, pageForMetrics: nil), // pageForMetrics is nil because it is set manually
            PullOfferLocation(stringTag: GlobalPositionPullOffers.pgTimeline, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.addBanks, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.financeAnalysis, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.financeTips, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.sanflixContract, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.suscriptionCardPG, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.sofiaPosition, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.gpOperate, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.onePlan, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.quickAccess, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.correosCash, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.world123SignUp, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.investmentPositionPT, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.officeAppointment, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.investmentsProposals, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.accountsAutomaticOperations, hasBanner: false, pageForMetrics: GlobalPositionPage().page)
        ]
    }
    
    public var personalAreaShortcuts: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.addBanks, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.financeAnalysis, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.financeTips, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.sanflixContract, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.suscriptionCardPG, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.sofiaPosition, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.gpOperate, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.onePlan, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.quickAccess, hasBanner: true, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: ClassicShortcutPullOffers.correosCash, hasBanner: true, pageForMetrics: GlobalPositionPage().page)
        ]
    }
    
    public var otherOperatives: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: OperatePullOffers.foreignCurrencyOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.donationsOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.solidarityOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.cardContractOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.accountContractOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.fxPayOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.inboxOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.insuranceContributionOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.insuranceChangePlanOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.insuranceActivatePlanOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.insurcanceSetupOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.suscriptionFundOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.internalTransferFundOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.ownershipCertificateOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: OperatePullOffers.transferOfContractsOperate, hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: "OPERAR_FONDO_SUSCRIPCION", hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: "OPERAR_FONDO_TRASPASO", hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: "PT_OPERAR_EXTRACT_ACCOUNT", hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: "PT_OPERAR_CONFIGURE_ALERT", hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: "OPERAR_CONTRATAR_CUENTAS", hasBanner: false, pageForMetrics: OtherOperativesPage().page),
            PullOfferLocation(stringTag: "OPERAR_OFFICE_APPOINTMENT", hasBanner: false, pageForMetrics: OtherOperativesPage().page)
        ]
    }
    
    public var whatsNew: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: WhatsNewPullOffers.operationInfo, hasBanner: true, pageForMetrics: WhatsNewPage().page),
            PullOfferLocation(stringTag: WhatsNewPullOffers.recobro, hasBanner: true, pageForMetrics: WhatsNewPage().page),
            PullOfferLocation(stringTag: WhatsNewPullOffers.agentMessage, hasBanner: true, pageForMetrics: WhatsNewPage().page),
            PullOfferLocation(stringTag: WhatsNewPullOffers.preconceived, hasBanner: false, pageForMetrics: WhatsNewPage().page),
            PullOfferLocation(stringTag: WhatsNewPullOffers.noPreconceived, hasBanner: true, pageForMetrics: WhatsNewPage().page)
        ]
    }
    
    public var pendingRequestPG: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: GlobalPositionPullOffers.contractsInboxPG, hasBanner: false, pageForMetrics: GlobalPositionPage().page)
        ]
    }
    
    public var pendingRequestRecovery: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: GlobalPositionPullOffers.recoveryN2, hasBanner: false, pageForMetrics: GlobalPositionPage().page),
            PullOfferLocation(stringTag: GlobalPositionPullOffers.recoveryN3, hasBanner: false, pageForMetrics: GlobalPositionPage().page)
        ]
    }
    
    public var pendingRequestWhatsNew: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: WhatsNewPullOffers.contractsInbox, hasBanner: false, pageForMetrics: WhatsNewPage().page)
        ]
    }
    
    // MARK: - Personal Area
    public var personalArea: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: PersonalAreaPullOffers.personalAreaDocumentary, hasBanner: false, pageForMetrics: PersonalAreaPage().page),
            PullOfferLocation(stringTag: PersonalAreaPullOffers.recovery, hasBanner: false, pageForMetrics: PersonalAreaPage().page)
        ]
    }
    
    public var personalAreaNamePage: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: PersonalAreaPullOffers.contactData, hasBanner: false, pageForMetrics: PersonalAreaNamePage().page),
            PullOfferLocation(stringTag: PersonalAreaPullOffers.contactDataDNI, hasBanner: false, pageForMetrics: PersonalAreaNamePage().page),
            PullOfferLocation(stringTag: PersonalAreaPullOffers.gdpr, hasBanner: false, pageForMetrics: PersonalAreaNamePage().page)
        ]
    }
    
    public var personalAreaAlertsConfig: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: PersonalAreaPullOffers.configAlerts, hasBanner: false, pageForMetrics: PersonalAreaConfigurationPage().page)
        ]
    }
    
    public var personalAreaConfigPG: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: PersonalAreaPullOffers.discreteModeVideo, hasBanner: false, pageForMetrics: PersonalAreaConfigurationPGPage().page),
            PullOfferLocation(stringTag: "OPERAR_PG", hasBanner: false, pageForMetrics: PersonalAreaPage().page)
        ]
    }
    
    public var securityArea: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: SecurityAreaPullOffers.contact, hasBanner: false, pageForMetrics: SecurityAreaPage().page),
            PullOfferLocation(stringTag: SecurityAreaPullOffers.deviceSecurityVideo, hasBanner: false, pageForMetrics: SecurityAreaPage().page),
            PullOfferLocation(stringTag: SecurityAreaPullOffers.personalAreaAlert, hasBanner: false, pageForMetrics: SecurityAreaPage().page),
            PullOfferLocation(stringTag: SecurityAreaPullOffers.thirtPartyPermissions, hasBanner: false, pageForMetrics: SecurityAreaPage().page),
            PullOfferLocation(stringTag: SecurityAreaPullOffers.safeBoxSecurity, hasBanner: false, pageForMetrics: SecurityAreaPage().page),
            PullOfferLocation(stringTag: SecurityAreaPullOffers.onlineProtection, hasBanner: false, pageForMetrics: SecurityAreaPage().page),
            PullOfferLocation(stringTag: SecurityAreaPullOffers.safeBoxSecurityNoOne, hasBanner: false, pageForMetrics: SecurityAreaPage().page)
        ]
    }
    
    public var secureDeviceTutorial: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: PersonalAreaPullOffers.secureDeviceTutorial, hasBanner: false, pageForMetrics: nil) // without metrics page
        ]
    }
    
    // MARK: - Menu
    
    public var myProducts: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: PrivateMenuPullOffers.sidebarStock, hasBanner: false, pageForMetrics: nil), // without metrics page in Excel
            PullOfferLocation(stringTag: PrivateMenuPullOffers.sidebarPensions, hasBanner: false, pageForMetrics: nil), // without metrics page in Excel
            PullOfferLocation(stringTag: PrivateMenuPullOffers.sidebarFunds, hasBanner: false, pageForMetrics: nil), // without metrics page in Excel
            PullOfferLocation(stringTag: PrivateMenuPullOffers.sidebarInsurance, hasBanner: false, pageForMetrics: nil), // without metrics page in Excel
            PullOfferLocation(stringTag: PrivateMenuPullOffers.menuTPV, hasBanner: false, pageForMetrics: nil), // without metrics page in Excel
            PullOfferLocation(stringTag: PrivateMenuPullOffers.sidebarDeposits, hasBanner: false, pageForMetrics: nil)
        ]
    }
    
    public var investmentSubmenuOffers: [PullOfferLocation] {
        [
            PullOfferLocation(
                stringTag: PrivateMenuPullOffers.sidebarInvestmentSubmenu1,
                hasBanner: false,
                pageForMetrics: nil
            ),
            PullOfferLocation(
                stringTag: PrivateMenuPullOffers.sidebarInvestmentSubmenu2,
                hasBanner: false,
                pageForMetrics: nil
            ),
            PullOfferLocation(
                stringTag: PrivateMenuPullOffers.sidebarInvestmentSubmenu3,
                hasBanner: false,
                pageForMetrics: nil
            ),
            PullOfferLocation(
                stringTag: PrivateMenuPullOffers.sidebarInvestmentSubmenu4,
                hasBanner: false,
                pageForMetrics: nil
            ),
            PullOfferLocation(
                stringTag: PrivateMenuPullOffers.sidebarInvestmentSubmenu5,
                hasBanner: false,
                pageForMetrics: nil
            ),
            PullOfferLocation(
                stringTag: PrivateMenuPullOffers.sidebarInvestmentSubmenu6,
                hasBanner: false,
                pageForMetrics: nil
            ),
            PullOfferLocation(
                stringTag: PrivateMenuPullOffers.sidebarInvestmentSubmenu7,
                hasBanner: false,
                pageForMetrics: nil
            ),
            PullOfferLocation(
                stringTag: PrivateMenuPullOffers.sidebarInvestmentSubmenu8,
                hasBanner: false,
                pageForMetrics: nil
            ),
            PullOfferLocation(
                stringTag: PrivateMenuPullOffers.menuInvestmentDeposit,
                hasBanner: false,
                pageForMetrics: nil
            )
        ]
    }
    
    public var manager: PullOfferLocation {
        PullOfferLocation(stringTag: PrivateMenuPullOffers.dateOfficeManager, hasBanner: false, pageForMetrics: PersonalManagerPage().page)
    }
    
    public var oldAnalysisArea: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: OldAnalysisAreaPullOffers.analysisCustomTip, hasBanner: true, pageForMetrics: OldAnalysisAreaPage().page),
            PullOfferLocation(stringTag: OldAnalysisAreaPullOffers.analysisMoneyPlan, hasBanner: true, pageForMetrics: OldAnalysisAreaPage().page),
            PullOfferLocation(stringTag: OldAnalysisAreaPullOffers.analysisPiggyBank, hasBanner: true, pageForMetrics: OldAnalysisAreaPage().page)
        ]
    }
    
    public var analysisArea: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: AnalysisAreaConstants.addOtherBanks, hasBanner: false, pageForMetrics: AnalysisAreaFinancialHealthPage().page),
            PullOfferLocation(stringTag: AnalysisAreaConstants.manageOtherBanks, hasBanner: false, pageForMetrics: AnalysisAreaFinancialHealthPage().page)
        ]
    }
    
    public var financing: [PullOfferLocation] {
        [
            PullOfferLocation(
                stringTag: FinancingConstants.needMoney,
                hasBanner: true,
                pageForMetrics: FinancingPage().page
            ),
            PullOfferLocation(
                stringTag: FinancingConstants.bigOffer,
                hasBanner: true,
                pageForMetrics: FinancingPage().page
            ),
            PullOfferLocation(
                stringTag: FinancingConstants.secondBigOffer,
                hasBanner: true,
                pageForMetrics: FinancingPage().page
            ),
            PullOfferLocation(
                stringTag: FinancingConstants.carousel,
                hasBanner: true,
                pageForMetrics: FinancingPage().page
            ),
            PullOfferLocation(
                stringTag: FinancingConstants.easyPayHighAmount,
                hasBanner: true,
                pageForMetrics: FinancingPage().page
            ),
            PullOfferLocation(
                stringTag: FinancingConstants.easyPayLowAmount,
                hasBanner: true,
                pageForMetrics: FinancingPage().page
            ),
            PullOfferLocation(
                stringTag: FinancingConstants.defaultersWeb,
                hasBanner: true,
                pageForMetrics: FinancingUpdatePage().page
            ),
            PullOfferLocation(
                stringTag: FinancingConstants.robinson,
                hasBanner: true,
                pageForMetrics: FinancingPage().page
            ),
            PullOfferLocation(
                stringTag: FinancingConstants.commercialOffer1,
                hasBanner: true,
                pageForMetrics: FinancingPage().page
            ),
            PullOfferLocation(
                stringTag: FinancingConstants.commercialOffer2,
                hasBanner: false,
                pageForMetrics: FinancingPage().page
            )
        ]
    }
    
    public var atm: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: AccountsPullOffers.atmReport, hasBanner: true, pageForMetrics: AtmPage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.atmOfficeAppointment, hasBanner: true, pageForMetrics: AtmPage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.customizeAtmOptions, hasBanner: true, pageForMetrics: AtmPage().page)
        ]
    }
    
    public var financingDistribution: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: "ZF_FINANCING_CARDS", hasBanner: true, pageForMetrics: FinancingDistributionPage().page)
        ]
    }
    
    // MARK: - Menu Public
    
    public var quickBalanceVideo: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: QuickBalancePullOffers.quickBalanceTutorialVideo, hasBanner: true, pageForMetrics: QuickBalancePage().page)
        ]
    }
    
    // MARK: - Accounts
    
    public var accountsTransactionDetail: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: AccountsPullOffers.lowEasyPayAmount, hasBanner: false, pageForMetrics: AccountTransactionDetail().page),
            PullOfferLocation(stringTag: AccountsPullOffers.highEasyPayAmount, hasBanner: false, pageForMetrics: AccountTransactionDetail().page),
            PullOfferLocation(stringTag: AccountsPullOffers.movAccountDetail, hasBanner: false, pageForMetrics: AccountTransactionDetail().page),
            PullOfferLocation(stringTag: AccountsPullOffers.lowEasyPayAmountDetail, hasBanner: false, pageForMetrics: AccountTransactionDetail().page),
            PullOfferLocation(stringTag: AccountsPullOffers.highEasyPayAmountDetail, hasBanner: false, pageForMetrics: AccountTransactionDetail().page),
            PullOfferLocation(stringTag: AccountsPullOffers.accountsHomePiggyBank, hasBanner: true, pageForMetrics: AccountTransactionDetail().page)
        ]
    }
    
    public var accountsOtherOperatives: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: AccountsPullOffers.fxPayAccountsHome, hasBanner: false, pageForMetrics: AccountsHomePage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.requestForeignCurrency, hasBanner: false, pageForMetrics: AccountsHomePage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.oneAcccountButton, hasBanner: false, pageForMetrics: AccountsHomePage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.newAccountButton, hasBanner: false, pageForMetrics: AccountsHomePage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.accountsHomeDonations, hasBanner: false, pageForMetrics: AccountsHomePage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.certificateAccountButton, hasBanner: false, pageForMetrics: AccountsHomePage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.correosCash, hasBanner: true, pageForMetrics: AccountsHomePage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.receiptFinancing, hasBanner: true, pageForMetrics: AccountsHomePage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.automaticOperations, hasBanner: true, pageForMetrics: AccountsHomePage().page)
        ]
    }
    
    public var accountsHomeLocations: [PullOfferLocation] {
        return [
            // MARK: pageForMetrics is nil because it is set manually
            PullOfferLocation(stringTag: GlobalPositionPullOffers.loansSimulator, hasBanner: false, pageForMetrics: nil)
        ]
    }
    
    // MARK: - Cards
    public var cards: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: CardsPullOffers.solidarity, hasBanner: false, pageForMetrics: CardsHomePage().page),
            PullOfferLocation(stringTag: CardsPullOffers.buyCard, hasBanner: false, pageForMetrics: CardsHomePage().page),
            PullOfferLocation(stringTag: CardsPullOffers.suscriptionCardsHome, hasBanner: false, pageForMetrics: CardsHomePage().page),
            PullOfferLocation(stringTag: CardsPullOffers.toolbarTooltipVideo, hasBanner: false, pageForMetrics: CardsHomePage().page),
            PullOfferLocation(stringTag: CardsPullOffers.financialBills, hasBanner: false, pageForMetrics: CardsHomePage().page),
            PullOfferLocation(stringTag: CardsPullOffers.homeCrossSelling, hasBanner: false, pageForMetrics: CardsHomePage().page)
        ]
    }
    
    public var suscriptionsM4M: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: CardsPullOffers.suscriptionM4M, hasBanner: false, pageForMetrics: CardControlDistributionPage().page)
        ]
    }
    
    public var billLocation: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: BillPullOffers.billPullOffer, hasBanner: false, pageForMetrics: BillHomePage().page)
        ]
    }
    
    // MARK: - Transfers
    public var countrySelector: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: TransferPullOffers.fxPayCurrencyCountry, hasBanner: true, pageForMetrics: SendMoneyPage().page)
        ]
    }
    
    public static var internalTransferSummary: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: TransferPullOffers.paymentSummary, hasBanner: false, pageForMetrics: InternalTransferSummaryPage().page)
        ]
    }
    
    public static func transferSummary(pageForMetrics: String? = nil) -> [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: AccountsPullOffers.lowEasyPayAmount, hasBanner: false, pageForMetrics: pageForMetrics),
            PullOfferLocation(stringTag: AccountsPullOffers.highEasyPayAmount, hasBanner: false, pageForMetrics: pageForMetrics),
            PullOfferLocation(stringTag: TransferPullOffers.paymentSummary, hasBanner: false, pageForMetrics: pageForMetrics)
        ]
    }
    
    // MARK: - Inbox
    public var inbox: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: InboxPullOffers.inboxContractSlider, hasBanner: false, pageForMetrics: InboxHomePage().page),
            PullOfferLocation(stringTag: InboxPullOffers.privateBankStatement, hasBanner: false, pageForMetrics: InboxHomePage().page),
            PullOfferLocation(stringTag: InboxPullOffers.inboxSetup, hasBanner: false, pageForMetrics: InboxHomePage().page),
            PullOfferLocation(stringTag: InboxPullOffers.inboxContract, hasBanner: false, pageForMetrics: InboxHomePage().page),
            PullOfferLocation(stringTag: InboxPullOffers.inboxMessages, hasBanner: false, pageForMetrics: InboxHomePage().page),
            PullOfferLocation(stringTag: InboxPullOffers.inboxDocumentation, hasBanner: false, pageForMetrics: InboxHomePage().page),
            PullOfferLocation(stringTag: InboxPullOffers.inboxFioc, hasBanner: false, pageForMetrics: InboxHomePage().page)
        ]
    }
    
    // MARK: - Help Center
    public var helpCenter: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: HelpCenterConstants.officeDate, hasBanner: false, pageForMetrics: HelpCenterPage().page),
            PullOfferLocation(stringTag: HelpCenterConstants.permanentAttention, hasBanner: false, pageForMetrics: HelpCenterPage().page),
            PullOfferLocation(stringTag: HelpCenterConstants.helpCenterVIP, hasBanner: false, pageForMetrics: HelpCenterPage().page)
        ]
    }
    
    // MARK: - Account Home CrossSelling
    public var accountHomeCrossSelling: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: AccountsPullOffers.homeCrossSelling, hasBanner: true, pageForMetrics: AccountsHomePage().page)
        ]
    }
    
    public var cardBoardingApplePay: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: CardBoardingConstants.welcomeOfferLocation, hasBanner: false, pageForMetrics: CardBoardingApplePayPage().page),
            PullOfferLocation(stringTag: CardBoardingConstants.confirmationOfferLocation, hasBanner: false, pageForMetrics: CardBoardingApplePayPage().page)
        ]
    }
    
    public var specificsLocations: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: CardsPullOffers.movCardDetails, hasBanner: true, pageForMetrics: CardsDetailMovementPage().page),
            PullOfferLocation(stringTag: AccountsPullOffers.movAccountDetail, hasBanner: true, pageForMetrics: AccountTransactionDetail().page),
            PullOfferLocation(stringTag: AccountsPullOffers.movAccountPfm, hasBanner: false, pageForMetrics: AccountTransactionDetail().page)
        ]
    }
    
    public var loginUnremembered: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: UnrememberedLoginPullOffers.publicTutorial, hasBanner: false, pageForMetrics: UnrememberedLoginPage().page)
        ]
    }
    
    public var loginReembered: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: LoginRememberedPullOffers.publicTutorialRec, hasBanner: false, pageForMetrics: LoginRememberedPage().page)
        ]
    }
    
    // MARK: - Bizum
    public var bizumHome: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: BizumHomeOffers.bizumPayGroup, hasBanner: false, pageForMetrics: BizumHomePage().page),
            PullOfferLocation(stringTag: BizumHomeOffers.bizumFundSent, hasBanner: false, pageForMetrics: BizumHomePage().page)
        ]
    }
    
    // MARK: - Ecommerce
    public var ecommerce: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: EcommerceConstants.publicTutorial, hasBanner: false, pageForMetrics: EcommercePage().page),
            PullOfferLocation(stringTag: EcommerceConstants.privateTutorial, hasBanner: false, pageForMetrics: EcommercePage().page)
        ]
    }
    
    // MARK: Santander key
    public static func secureDevicePG(_ pageForMetrics: String? = nil) -> PullOfferLocation {
        PullOfferLocation(stringTag: SecureDeviceConstants.tutorial, hasBanner: false, pageForMetrics: pageForMetrics)
    }
    
    // MARK: Send Money Operative
    public var sendMoneyEasyPay: [PullOfferLocation] {
        [
            PullOfferLocation(stringTag: SendMoneyOperativePullOffers.lowEasyPayAmount, hasBanner: false, pageForMetrics:
                                TransferOperativesConstant.NationalTransferSummary.page),
            PullOfferLocation(stringTag: SendMoneyOperativePullOffers.highEasyPayAmount, hasBanner: false, pageForMetrics:
                                TransferOperativesConstant.NationalTransferSummary.page)
        ]
    }
    
    // MARK: Private Side Menu
    public var privateSideMenu: [PullOfferLocationRepresentable] {
        let privateSide = [
            PullOfferLocation(stringTag: "FIRMA_ORDENES", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "PAGO_MOVIL", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_MENU_ONE1", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_MENU_ONE2", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "MENU_CONTRATAR_SANFLIX", hasBanner: false, pageForMetrics: nil),
            PullOfferLocation(stringTag: "HUELLA_CARBONO", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "MI_CASA_MENU", hasBanner: false, pageForMetrics: PrivateMenuPage().page)
        ] as [PullOfferLocation]
        return privateSide + myProductsSideMenu + sofiaInvestment + world123SideMenu
    }
    
    public var myProductsSideMenu: [PullOfferLocationRepresentable] {
        [PullOfferLocation(stringTag: "MENU_TPV", hasBanner: false, pageForMetrics: PrivateMenuPage().page)]
    }
    
    // MARK: - Sofia Investment
    public var sofiaInvestment: [PullOfferLocationRepresentable] {
        return [
            PullOfferLocation(stringTag: "FIRMA_ORDENES", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "ORDENES_NO_ASESORADAS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SOFIA_OPERAR", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SOFIA_ORDENES", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SOFIA_MOVIMIENTOS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SOFIA_PROPUESTAS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SOFIA_MERCADOS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SOFIA_FAVORITOS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SOFIA_ANALISIS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SOFIA_SMARTTRADER", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SOFIA_ORIENTA", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "MENU_INVESTMENT_INVEST", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "MENU_INVESTMENT_MIFID", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "MENU_INVESTMENT_EBROKER", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_MIFID_TEST", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_FUNDS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_MENU_INVESTMENT_FOREIGN_EXCHANGE", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_PENSION_PLANS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_MENU_INVESTMENT_ALERTS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_MENU_INVESTMENT_GUARANTEED", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_POSITION", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_STOCKS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_FIXED_RENT", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_GUARANTEED", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_FOREINGN_EXCHANGE", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_ALERTS", hasBanner: false, pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_ROBOADVISOR", hasBanner: false, pageForMetrics: PrivateMenuPage().page)
        ]
    }
    
    public var world123SideMenu: [PullOfferLocationRepresentable] {
        [
            PullOfferLocation(stringTag: "MUNDO123_MENU_SIMULATE", hasBanner: false,
                              pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "MUNDO123_MENU_WHATHAVE", hasBanner: false,
                              pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "MUNDO123_MENU_BENEFITS", hasBanner: false,
                              pageForMetrics: PrivateMenuPage().page),
            PullOfferLocation(stringTag: "MUNDO123_MENU_SIGNUP", hasBanner: false,
                              pageForMetrics: PrivateMenuPage().page)]
    }
    
    public var santanderOne1: [PullOfferLocationRepresentable] {
        [
            PullOfferLocation(stringTag: "SIDE_MENU_ONE1", hasBanner: false,
                              pageForMetrics: PrivateMenuPage().page)
        ]
    }
    
    public var santanderOne2: [PullOfferLocationRepresentable] {
        [
            PullOfferLocation(stringTag: "SIDE_MENU_ONE2", hasBanner: false,
                              pageForMetrics: PrivateMenuPage().page)
        ]
    }
    
    public var privateMenuSanflix: [PullOfferLocationRepresentable] {
        [
            PullOfferLocation(stringTag: "MENU_CONTRATAR_SANFLIX",
                              hasBanner: false, pageForMetrics: nil)
        ]
    }
    
    public var privateMenuMyHome: [PullOfferLocationRepresentable] {
        [
            PullOfferLocation(stringTag: "MI_CASA_MENU", hasBanner: false,
                              pageForMetrics: PrivateMenuPage().page)
        ]
    }
    
    public var privateMenuCarbonFootPrint: [PullOfferLocationRepresentable] {
        [
            PullOfferLocation(stringTag: "HUELLA_CARBONO", hasBanner: false,
                              pageForMetrics: PrivateMenuPage().page)
        ]
    }
    
    public var privateMenuManager: [PullOfferLocationRepresentable] {
        [
            PullOfferLocation(stringTag: "MENU_MIGESTOR", hasBanner: true, pageForMetrics: PrivateMenuPage().page)
        ]
    }
    
    public func getLocationRepresentable(locations: [PullOfferLocationRepresentable], location: String) -> PullOfferLocationRepresentable? {
        return locations.first { $0.stringTag == location }
    }
}
