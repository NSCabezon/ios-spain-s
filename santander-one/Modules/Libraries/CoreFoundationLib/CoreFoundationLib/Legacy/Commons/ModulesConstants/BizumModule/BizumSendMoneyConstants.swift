
public struct BizumContactPage: PageWithActionTrackable {
    public let strategy: TrackerPageAssociated?
    public typealias ActionType = Action
    public let page: String
    public enum Action: String {
        case phoneNumber = "numero"
        case contacts = "agenda"
        case frequentContact = "contacto_frecuente"
        case addNew = "añadir_mas"
        case removeContact = "eliminar_contacto"
        case confirmRemoveContact = "confirmar_eliminar_contacto"
    }
    
    public init(strategy: TrackerPageAssociated? = nil) {
        self.strategy = strategy
        self.page = strategy?.pageAssociated ?? ""
    }
}

public struct BizumSendMoneyAccountSelectorPage: PageTrackable {
    public let page = "bizum_envio_dinero_selector_cuenta"
    public init() {}
}

public struct BizumContactSendMoneyPage: TrackerPageAssociated {
    public let pageAssociated = "bizum_envio_dinero"
    public init() {}
}

public struct BizumContactRequestMoneyPage: TrackerPageAssociated {
    public let pageAssociated = "bizum_solicitar_dinero"
    public init() {}
}

public struct BizumContactListPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum_agenda"
    public enum Action: String {
        case permissions = "permisos"
        case search = "buscar"
        case contact = "contacto"
    }
    
    public init() {}
}

public struct BizumSendMoneyConfirmationPage: PageWithActionTrackable {
    public let page = "bizum_envio_dinero_confirmacion"
    
    public init() {}
}

public struct BizumAmountSendMoneyPage: TrackerPageAssociated {
    public let pageAssociated: String = "bizum_envio_dinero_importe"
    public init() {}
}

public struct BizumAmountRequestMoneyPage: TrackerPageAssociated {
    public let pageAssociated: String = "bizum_solicitar_dinero_importe"
    public init() {}
}

public struct BizumNoRegisterToolTipSendMoneyPage: PageWithActionTrackable {
    public let page: String = "bizum_envio_dinero_no_alta"
    public init() {}
}

public struct BizumNoRegisterToolTipRequestMoneyPage: PageWithActionTrackable {
    public let page: String = "bizum_solicitar_dinero_no_alta"
    public init() {}
}

public struct BizumSendMoneySignaturePage: PageTrackable {
    public let page = "bizum_envio_dinero_firma"
    public init() {}
}

public struct BizumSendMoneyOTPPage: PageTrackable {
    public let page = "bizum_envio_dinero_otp"
    public init() {}
}

public struct BizumSendMoneySummaryPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum_envio_dinero_resumen"
    public enum Action: String {
        case share = "compartir"
    }
    public init() {}
}
