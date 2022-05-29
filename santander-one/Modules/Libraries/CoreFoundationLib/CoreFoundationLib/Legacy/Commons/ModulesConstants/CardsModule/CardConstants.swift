
public struct CardConstants {
    public static let isInAppEnrollmentEnabled = "enableInAppEnrollment"
    public static let isEnableCardsHomeLocationMap = "enableCardsHomeLocationMap"
    public static let isOnOffEnableForRetailUsers = "enableOnOffCardsForRetailUsers"
    public static let isOnOffEnableForPBUsers = "enableOnOffCardsForPBUsers"
    public static let isEnableCashWithDrawal = "enableCashWithdrawal"
    public static let isEnableCesEnrollment = "enableCesEnrollment"
    public static let isEnableLimitsChangeCards = "enableLimitsChangeCards"
    public static let isEnabledM4M = "enabledM4M"
    public static let isM4MactiveSuscriptionEnabled = "enabledM4MactiveSuscription"
}

public struct CardsPullOffers {
    public static let solidarity = "REDONDEO_SOLIDARIO"
    public static let buyCard = "CONTRATAR_TARJETAS"
    public static let suscriptionCardsHome = "SUSCRIPTION_CARD_CARDSHOME"
    public static let movCardDetails = "MOV_TAR_DETAIL"
    public static let toolbarTooltipVideo = "CARD_TOOLBAR_TOOLTIP_VIDEO"
    public static let suscriptionM4M = "SUSCRIPTION_CARD_M4M_DISTRIBUTION"
    public static let financialBills = "CREDITCARD_RECIBOS_FINANCIAL"
    public static let homeCrossSelling = "CARDS_HOME_CROSSSELLING"
}

public struct CardsHomePage: PageWithActionTrackable, EmmaTrackable {
    public let emmaToken: String
    public typealias ActionType = Action
    
    public let page =  "/card"
    
    public enum Action: String {
        case tooltip = "click_info_tooltip"
        case copyPan = "copy_card_pan"
        case swipe = "swipe_cards_carrousel"
        case cvv = "view_cvv"
        case map = "view_purchase_map"
        case changePaymentMethod = "click_change_payment_method"
        case operative = "click_operative"
        case applePay = "click_apple_pay"
        case pendingTransaction = "filter_unsettled_transaction"
        case nextSettlement = "view_next_settlement"
    }
    public init() {
        self.emmaToken = ""
    }
    public init(emmaToken: String) {
        self.emmaToken = emmaToken
    }
}

public struct CardDetailPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page =  "/card/detail"
    
    public enum Action: String {
        case changeAlias = "change_alias"
        case copyPan = "copy_pan"
    }
    public init() {}
}

public struct ApplePayPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "tarjetas_pagar"
    
    public enum Action: String {
        case wallet = "boton_wallet"
    }
    public init() {}
}

public struct CardsSearchPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/card/filter"
    
    public enum Action: String {
        case apply = "apply_filter"
    }
    public init() {}
}

public struct ActivateCardSummaryPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/cardboarding/activate/thankyou"
    
    public enum Action: String {
        case exit = "click_exit"
        case activate = "click_activate"
    }
    public init() {}
}

public struct CardBoardingWelcomePage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "onboarding_tarjetas_welcome"
    
    public enum Action: String {
        case exit = "ahora_no"
        case configure = "configurar"
    }
    public init() {}
}

public struct StartUsingCardPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/cardboarding/activate"
    
    public enum Action: String {
        case close = "click_not_now"
        case activate = "unlock_card"
    }
    public init() {}
}

public struct CardBoardingActivationSignaturePage: PageTrackable {
    public let page = "/cardboarding/activate/signature"
    public init() {}
}

public struct CardsDetailMovementPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/card/transaction/detail"
    
    public enum Action: String {
        case shareLink = "share_transaction_link"
        case share = "share_transaction"
        case map = "view_purchase_map"
        case expensesDivide = "split_expense"
        case offCard = "turnoff_card"
        case fraud = "fraude"
    }
    public init() {}
}

public struct CardPendingTransactionPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public init() {}
    public let page = "/card/pend_settlement/detail"
    public enum Action: String {
        case offCard = "turnoff_card"
        case share = "share_transaction"
        case instantCash = "click_instant_cash"
    }
}

public enum CardFilterOperationType: String {
    case operationType = "tipo_operacion"
}

public enum CardBoardingConstants {
    public static let welcomeOfferLocation = "CB_IN_APP"
    public static let confirmationOfferLocation = "CB_IN_APP_HELP"
    public static let cardBoardingSteps = "cardBoardingSteps"
    public static let maxAliasChars = 20
}

public struct CardBoardingApplePayPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public init() {}
    public let page = "onboarding_tarjetas_personalizar_apple_pay"
    public enum Action: String {
        case applePayEnrollment = "onboarding_tarjetas_enrolar"
    }
}

public struct CardBoardingChangePaymentMethodPage: PageTrackable {
    public init() {}
    public let page = "onboarding_tarjetas_personalizar_modificar_forma_pago"
}

public struct CardBoardingSummaryPage: PageTrackable {
    public init() {}
    public let page = "onboarding_tarjetas_final"
}

public struct CardBoardignGeolocationPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public init() {}
    public let page = "onboarding_tarjetas_personalizar_geoposicionamiento"
    public enum Action: String {
        case activateLocation = "activar_geoposicionamiento"
        case deactivateLocation = "desactivar_geoposicionamiento"
    }
}

public struct CardBlockReasonPage: PageTrackable {
    public init() {}
    public let page = "/card/block/reason"
}

public struct CardBlockSignaturePage: PageTrackable {
    public init() {}
    public let page = "/card/block/signature"
}

public struct CardBlockSummaryPage: PageTrackable {
    public init() {}
    public let page = "/card/block/thankyou"
}

public struct CardOnSignaturePage: PageTrackable {
    public init() {}
    public let page = "/card/turn_on/signature"
}

public struct CardOffSignaturePage: PageTrackable {
    public init() {}
    public let page = "/card/turn_off/signature"
}

public struct CardOnOffSummaryPage: PageTrackable {
    public let page: String
    public init(page: String) {
        self.page = page
    }
}

public struct CardOnSummaryPage: PageTrackable {
    public init() {}
    public let page = "/card/turn_on/thankyou"
}

public struct CardOffSummaryPage: PageTrackable {
    public init() {}
    public let page = "/card/turn_off/thankyou"
}
