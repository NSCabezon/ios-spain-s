import CoreDomain

public struct GlobalPositionConstants {
    public static let smartPgType = "smrt"
    public static let classicPgType = "class"
    public static let simplePgType = "smpl"
    public static let carouselPageName = "banners_carousel_TOP_GP"
}

public enum GlobalPositionType: String, CaseIterable {
    case simple
    case classic
    case smart
}

public struct GlobalPositionPullOffers {
    public static let pgCta = "PG_CTA"
    public static let pgTar = "PG_TAR"
    public static let pgVal = "PG_VAL"
    public static let pgFon = "PG_FON"
    public static let pgDep = "PG_DEP"
    public static let pgPla = "PG_PLA"
    public static let pgPre = "PG_PRE"
    public static let pgTop = "PG_TOP"
    public static let pgSai = "PG_SAI"
    public static let pgSpr = "PG_SPR"
    public static let pgSav = "PG_SAV"
    public static let pgCtaNo = "PG_CTA_NO"
    public static let pgCtaBelow = "PG_CTA_BELOW"
    public static let pgTarNo = "PG_TAR_NO"
    public static let pgTarBelow = "PG_TAR_BELOW"
    public static let pgValNo = "PG_VAL_NO"
    public static let pgValBelow = "PG_VAL_BELOW"
    public static let pgFonNo = "PG_FON_NO"
    public static let pgFonBelow = "PG_FON_BELOW"
    public static let pgDepNo = "PG_DEP_NO"
    public static let pgDepBelow = "PG_DEP_BELOW"
    public static let pgPlaNo = "PG_PLA_NO"
    public static let pgPlaBelow = "PG_PLA_BELOW"
    public static let pgPreNo = "PG_PRE_NO"
    public static let pgPreBelow = "PG_PRE_BELOW"
    public static let pgSaiNo = "PG_SAI_NO"
    public static let pgSaiBelow = "PG_SAI_BELOW"
    public static let pgSprNo = "PG_SPR_NO"
    public static let pgSprBelow = "PG_SPR_BELOW"
    public static let pgSavNo = "PG_SAV_NO"
    public static let pgSavBelow = "PG_SAV_BELOW"
    public static let happyBirthday = "HAPPY_BIRTHDAY"
    
    public static let pgTimeline = "PG_TIMELINE"
    public static let loansSimulator = "SIMULADOR_PRECONCEDIDO"
    public static let contractsInboxPG = "PG_BUZON_CONTRATOS"
    public static let recoveryN2 = "PG_RECOVERY_N2"
    public static let recoveryN3 = "PG_RECOVERY_N3"
    
    public static let pgTopPregrantedOfferId = "PRE_CONCEDIDOS"
    public static let pgTopPregrantedRobinsonOfferId = "PRE_CONCEDIDOS_ROBINSON"
}

// MARK: - Tracker

public struct GlobalPositionPage: PageWithActionTrackable, EmmaTrackable {
    public let emmaToken: String
    public typealias ActionType = Action
    public let page = "/global_position"
    
    public enum Action: String {
        case accountCollapse = "fold_account"
        case accountExpand = "unfold_account"
        case cardCollapse = "fold_card"
        case cardExpand = "unfold_card"
        case stockAccountCollapse = "fold_share"
        case stockAccountExpand = "unfold_share"
        case fundCollapse = "fold_fund"
        case fundExpand = "unfold_fund"
        case depositCollapse = "fold_deposit"
        case depositExpand = "unfold_deposit"
        case pensionCollapse = "fold_pension_plan"
        case pensionExpand = "unfold_pension_plan"
        case loanCollapse = "fold_loan"
        case loanExpand = "unfold_loan"
        case savingProductCollapse = "fold_saving_product"
        case savingProductExpand = "unfold_saving_product"
        case insuranceSavingCollapse = "fold_saving_insurance"
        case insuranceSavingExpand = "unfold_saving_insurance"
        case insuranceProtectionCollapse = "fold_insurance"
        case insuranceProtectionExpand = "unfold_insurance"
        case operate = "click_operate"
        case contract = "click_purchase"
        case bills = "click_bill"
        case bizum = "send_money"
        case moreActions = "click_more_options"
        case newShippment = "click_new_sending_from_carrousel"
        case newFavContact = "click_new_contact_from_carrousel"
        case editExpenses = "click_budget"
        case timeline = "click_timeline"
        case registerSecureDevice = "register_secure_device"
        case updateSecureDevice = "update_secure_device"
        case swipeCarousel = "swipe_carrousel"
        case bubble = "click_whatsnew"
        case pregrantedBanner = "click_pregranted_banner"
        case historicSendMoney = "view_history"
        case carbonFootprint = "carbon_footprint"
    }    
    public init() {
        self.emmaToken = ""
    }
    public init(emmaToken: String) {
        self.emmaToken = emmaToken
    }
    
    public func foldingActionTrack(type: ProductTypeEntity, isOpen: Bool) -> Action? {
        let valuesIfOpen: [ProductTypeEntity: Action] = [
            .account: .accountExpand,
            .card: .cardExpand,
            .deposit: .depositExpand,
            .loan: .loanExpand,
            .savingProduct: .savingProductExpand,
            .stockAccount: .stockAccountExpand,
            .pension: .pensionExpand,
            .fund: .fundExpand,
            .insuranceSaving: .insuranceSavingExpand,
            .insuranceProtection: .insuranceProtectionExpand
        ]
        let valuesIfClosed: [ProductTypeEntity: Action] = [
            .account: .accountCollapse,
            .card: .cardCollapse,
            .deposit: .depositCollapse,
            .loan: .loanCollapse,
            .savingProduct: .savingProductCollapse,
            .stockAccount: .stockAccountCollapse,
            .pension: .pensionCollapse,
            .fund: .fundCollapse,
            .insuranceSaving: .insuranceSavingCollapse,
            .insuranceProtection: .insuranceProtectionCollapse
        ]
        return isOpen ? valuesIfOpen[type]: valuesIfClosed[type]
    }
}

public struct GlobalPositionLoanSimulatorPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "pos_global_preconcedidos"
    
    public enum Action: String {
        case enterMaxValue = "maximo"
        case changeAmountSlider = "slide_maximo"
        case changeMonthSlider = "slide_numero_meses"
        case enterMonths = "numero_meses"
        case moreInfo = "mas_info"
    }
    public init() {}
}

public struct GlobalPositionBudgetPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/global_position/budget"
    
    public enum Action: String {
        case slide = "change_expense_slide"
        case save = "click_save_budget"
    }
    public init() {}
}

public struct GlobalPositionContextsPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/global_position/context_list"

    public enum Action: String {
        case unfoldContextList = "unfold_context_list"
        case selectNew = "select_new_context"
        case selectSame = "select_same_context"
        case showAll = "click_show_all_contexts"
        case cancel = "click_cancel"
        case apiError = "api_error"
    }
    public init() {}
}

public struct ClassicShortcutPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "accesos_directos"
    
    public enum Action: String {
        case action = "accion"
    }
    public init() {}
}

public enum ClassicShortcutPullOffers {
    public static let gpOperate = "OPERAR_PG"
    public static let sofiaPosition = "SOFIA_POSICION"
    public static let addBanks = "AGREGAR_BANCOS"
    public static let financeAnalysis = "ANALISIS_FINANCIERO"
    public static let financeTips = "CONSEJOS_FINANCIEROS"
    public static let suscriptionCardPG = "SUSCRIPTION_CARD_PG"
    public static let sanflixContract = "CONTRATAR_SANFLIX"
    public static let onePlan = "DIRECT_ACCESS_PG_ONE"
    public static let quickAccess = "PG_ACCESOS_DIRECTOS"
    public static let correosCash = "CORREOS_CASH_PG"
    public static let world123SignUp = "MUNDO123_MENU_SIGNUP"
    public static let investmentPositionPT = "PT_INVESTMENT_POSITION"
    public static let officeAppointment = "DIRECT_ACCESS_PG_OFFICE_APPOINTMENT"
    public static let investmentsProposals = "DIRECT_ACCESS_PG_INVESTMENT_PROPOSAL"
    public static let accountsAutomaticOperations = "DIRECT_ACCESS_PG_AUTOMATIC_OPERATIONS"
}
