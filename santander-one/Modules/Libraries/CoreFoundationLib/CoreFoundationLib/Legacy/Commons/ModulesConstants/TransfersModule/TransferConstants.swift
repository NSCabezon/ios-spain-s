
public struct TransferConstant {
    public static let appConfigEmittedTransfersMaxPagination = "emittedTransfersMaxPagination"
    public static let appConfigEmittedTransfersSearchMonths = "emittedTransfersSearchMonths"
    public static let appConfigReceivedTransfersMaxPagination = "receivedTransfersMaxPagination"
    public static let appReceivedTransfersSearchMonths = "receivedTransfersSearchMonths"
    public static let appConfigEnableNationalTransferPreLiquidations = "enableNationalTransferPreLiquidations"
    public static let appConfigNationalTransferInformation = "nationalTransferInformation"
    public static let appConfigInmediateTransferInformation = "immediateTransferInformation"
    public static let appConfigUrgentTransferInformation = "urgentTransferInformation"
    public static let appConfigInstantNationalTransfersMaxAmount = "instantNationalTransfersMaxAmount"
}

public struct TransferPullOffers {
    public static let fxpayTransferHomeOffer = "FXPAY_TRANSFER_HOME"
    public static let tooltipVideo = "TRANSFER_TUTORIAL_VIDEO"
    public static let donationTransferOffer = "TRANSFER_HOME_DONATIONS"
    public static let fxPayCurrencyCountry = "FXPAY"
    public static let paymentSummary = "TRANSFERENCIA_RESUMEN_PAGOS"
    public static let correosCashOffer = "CORREOS_CASH_TRANSFER_HOME"
}

public struct InternalTransferSelectOriginPage: PageTrackable {
    public let page = "transferencias_traspasos_seleccion_cuenta_origen"
    public init() {}
}

public struct InternalTransferSelectDestinationPage: PageTrackable {
    public let page = "transferencias_traspasos_seleccion_cuenta_destino"
    public init() {}
}

public struct InternalTransferAmountConceptPage: PageTrackable {
    public let page = "transferencias_traspasos_importe_y_concepto"
    public init() {}
}

public struct InternalTransferConfirmationPage: PageWithActionTrackable {
    public let page = "transferencias_traspasos_confirmacion"
    public init() {}
}

public struct ScheduledTransferPage: PageTrackable {
    public let page = "transferencias_home_programadas"
    public init() {}
}

public struct InternalTransferSignaturePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "transferencias_traspasos_firma"
    public enum Action: String {
        case error
    }
    public init() {}
}

public struct ContactSelectorPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "envio_dinero_destinatarios_favoritos"
    public enum Action: String {
        case order = "ordenar_favorito"
        case share = "compartir_favorito"
        case newContact = "nuevo_destinatario"
        case showFavorite = "ver_favorito"
    }
    public init() {}
}

public struct InternalTransferFaqPage: PageTrackable {
    public let page = "faq_traspasos"
    public init() {}
}

public struct InternalTransferOTPPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "transferencias_traspasos_otp"
    public enum Action: String {
        case error
    }
    public init() {}
}

// If Summary will be custom, the summary page will be into operative class
public struct InternalTransferSummaryPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "transferencias_traspasos_resumen"
    public enum Action: String {
        case opinator = "ayudanos_a_mejorar"
        case share = "compartir"
        case pdf = "ver_pdf"
    }
    public init() {}
}

public struct SendMoneyPage: PageWithActionTrackable, EmmaTrackable {
    public typealias ActionType = Action
    public let page = "envio_dinero"
    public let emmaToken: String
    public enum Action: String {
        case tooltip = "tooltip"
        case newSend = "nuevo_envio"
        case swipeFavorites = "swipe_favoritos"
        case favoriteDetail = "detalle_favorito"
        case newFavorite = "nuevo_favorito"
        case seeFavorites = "ver_favoritos"
        case swipeEmmited = "swipe_emitidas"
        case emmited = "emitida"
        case received = "recibida"
        case seeHistoric = "ver_historico"
        case transfer = "transferencia"
        case internalTransfer = "traspaso"
        case moneyCode = "sacar_dinero_con_codigo"
        case scheduled = "programadas"
        case anotherQueries = "otras_consultas"
    }
    public init() {
        self.emmaToken = ""
    }
    public init(emmaToken: String) {
        self.emmaToken = emmaToken
    }
}

public struct SendMoneyDetailFavoritePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "envio_dinero_detalle_favorito"
    public enum Action: String {
        case share = "compartir"
        case newSend = "nuevo_envio"
        case edit = "editar"
        case delete = "borrar"
    }
    public init() {}
}

public struct SendMoneyHistoryPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "envio_dinero_historico"
    public enum Action: String {
        case type = "tipo"
        case filter = "filtro"
        case detail = "ver_detalle"
    }
    public init() {}
}

public struct SendMoneyScheduledPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "envio_dinero_programadas"
    public enum Action: String {
        case type = "tipo"
        case new = "nuevo"
        case detail = "ver_detalle"
    }
    public init() {}
}

public struct GPSendMoneyPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/global_position/send_money"
    public enum Action: String {
        case transfer = "click_transfer"
        case internalTransfer = "click_switch"
        case onePayFX = "click_onepayfx"
        case codeWithdraw = "click_withdraw_with_code"
    }
    public init() {}
}

public struct NewFavouriteAliasPage: PageTrackable {
    public let page = "transferencias_alta_favorito_destino"
    public init() {}
}

public struct NewFavouriteConfirmationPage: PageTrackable {
    public let page = "transferencias_alta_favorito_sepa_confirmacion"
    public init() {}
}

public struct NewFavouriteSummaryPage: PageTrackable {
    public let page = "transferencias_alta_favorito_sepa_resumen"
    public init() {}
}

public struct DeleteFavouriteConfirmationSepaPage: TrackerPageAssociated {
    public let pageAssociated = "transferencias_baja_favorito_sepa_confirmacion"
    public init() {}
}

public struct DeleteFavouriteConfirmationNoSepaPage: TrackerPageAssociated {
    public let pageAssociated = "transferencias_baja_favorito_no_sepa_confirmacion"
    public init() {}
}

public struct DeleteFavouriteSepaSummaryPage: TrackerPageAssociated {
    public let pageAssociated = "transferencias_baja_favorito_sepa_resumen"
    public init() {}
}

public struct DeleteFavouriteNoSepaSummaryPage: TrackerPageAssociated {
    public let pageAssociated = "transferencias_baja_favorito_no_sepa_resumen"
    public init() {}
}

public struct DeleteFavouriteSepaSignaturePage: TrackerPageAssociated {
    public let pageAssociated = "transferencias_baja_favorito_sepa_firma"
    public init() {}
}

public struct DeleteFavouriteNoSepaSignaturePage: TrackerPageAssociated {
    public let pageAssociated = "transferencias_baja_favorito_no_sepa_firma"
    public init() {}
}

public struct DeleteScheduledTransferSignaturePage: TrackerPageAssociated {
    public let pageAssociated = "transferencias_programadas_baja_firma"
    public init() {}
}

public struct DeleteScheduledTransferResumePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "transferencias_programadas_baja_resumen"
    public enum Action: String {
        case share = "compartir"
        case feedback = "ayudanos_a_mejorar"
    }
    public init() {}
}

public struct EditFavouriteHolderAndAccountPage: PageTrackable {
    public let page = "transferencias_alta_favorito_destino"
    public init() {}
}

public struct EditFavouriteConfirmationPage: PageTrackable {
    public let page = "transferencias_alta_favorito_sepa_confirmacion"
    public init() {}
}

public struct EditFavouriteSummaryPage: PageTrackable {
    public let page = "transferencias_alta_favorito_sepa_resumen"
    public init() {}
}

public struct SendMoneyRecipientAccountPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/send_money/transfer/recipient"
    public enum Action: String {
        case selectFavourite = "select_favourite"
        case viewAllFavourites = "view_all_favourites"
        case addNewContact = "add_new_contact"
        case selectRecentTransfer = "select_recent_transfer"
        case selectNewRecipient = "select_new_recipient"
        case changeCountry = "change_country"
    }
    public init() {}
}

public struct SendMoneySourceAccountPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/send_money/transfer/origin_account"
    public enum Action: String {
      case viewHiddenAccounts = "view_hidden_accounts"
    }
    public init() {}
}

public struct SendMoneyAmountAndDatePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public var page: String
    public enum Action: String {
        case changeCurrency = "change_currency"
        case paymentCost = "payment_cost"
        case fileDownload = "file_download"
    }
    public init(national: Bool, type: String) {
        self.page = national ? "/send_money/transfer/amount_date" : "/send_money/transfer/int/\(type.lowercased().notWhitespaces())/amount_date"
    }
}

public struct SendMoneyTransferTypePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/send_money/transfer/send_type"
    public enum Action: String {
      case clickTooltip = "click_tooltip"
    }
    public init() {}
}

public struct SendMoneyConfirmationPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public var page: String
    public enum Action: String {
        case notifyEmail = "notify_by_email"
    }
    public init(national: Bool, type: String) {
        self.page = national ? "/send_money/transfer/confirm" : "/send_money/transfer/int/\(type.lowercased().notWhitespaces())/confirm"
    }
}

public struct SendMoneySummaryPage: PageWithActionTrackable {
    public var page: String
    public enum Action: String {
        case fileDownload = "file_download"
        case share = "share"
        case seeSummary = "see_summary"
        case seeFinancingOptions = "see_financing_options"
    }
    public init(national: Bool, type: String) {
        self.page = national ? "/send_money/transfer/thank_you" : "/send_money/transfer/int/\(type.lowercased().notWhitespaces())/thank_you"
    }
}
