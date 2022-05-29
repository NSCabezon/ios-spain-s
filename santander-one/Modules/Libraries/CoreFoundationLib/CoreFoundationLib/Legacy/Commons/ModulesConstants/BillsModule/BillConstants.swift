
public struct BillPullOffers {
    public static let billPullOffer = "RECIBOS_FINANCIAL_HOME"
}

public struct BillsConstants {
    public static let relativeURl = "RWD/entidades/iconos"
    public static let iconBankExtension = ".png"
    public static let monthsLimit = "billsHomeMonthsLimit"
    public static let enableBillAndTaxesRemedy = "enableBillAndTaxesRemedy"
}

public struct BillHomePage: PageWithActionTrackable, EmmaTrackable {
    public let emmaToken: String
    public typealias ActionType = Action
    
    public let page = "recibos_impuesto"
    
    public enum Action: String {
        case tooltip = "tooltip"
        case doPayment = "realizar_pago"
        case domicile = "domiciliar"
        case financial = "agenda_financiera"
        case swipe = "swipe"
        case nextBill = "proximo_recibo"
        case filter = "filtro"
        case billType = "tipo_recibo"
        case billPayment = "pago_recibos_otras_emisoras"
        case bill = "pago_recibos_recibos"
        case taxes = "pago_recibos_impuestos"

    }
    public init() {
        self.emmaToken = ""
    }
    public init(emmaToken: String) {
        self.emmaToken = emmaToken
    }
}

public struct BillSearchFiltersPage: PageWithActionTrackable {
    public typealias ActionType = Action

    public let page = "recibos_impuesto_filtro"

    public enum Action: String {
        case apply = "aplicar"
    }
    public init() {}
}

public struct BillEmittersPaymentAccountSelectorPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "pago_recibos_otras_emisoras_seleccion_cuenta"
    public enum Action: String {
        case faq
    }
    public init() {}
}

public struct BillEmittersManualPaymentPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "pago_recibos_otras_emisoras_formulario"
    public enum Action: String {
        case faq
    }
    public init() {}
}

public struct BillEmittersPaymentConfirmationPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "pago_recibos_otras_emisoras_confirmacion"
    public enum Action: String {
        case faq
    }
    public init() {}
}

public struct BillEmittersPaymentSummaryPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "pago_recibos_otras_emisoras_resumen"
    public enum Action: String {
        case share = "compartir"
    }
    public init() {}
}

public struct BillEmittersPaymentFaqPage: PageTrackable {
    public let page = "faq_recibos_otras_emisoras"
    public init() {}
}

public struct SearchEmittersPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "pago_recibos_otras_emisoras_busqueda"
    public enum Action: String {
        case faq
    }
    public init() {}
}

public struct BillEmittersPaymentSignaturePage: PageTrackable {
    public let page = "pago_recibos_otras_emisoras_firma"
    public init() {}
}
