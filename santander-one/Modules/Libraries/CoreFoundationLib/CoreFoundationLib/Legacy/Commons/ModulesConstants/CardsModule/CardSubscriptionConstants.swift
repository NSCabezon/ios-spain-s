//
//  CardSubscriptionConstants.swift
//  Commons
//
//  Created by Ignacio González Miró on 13/4/21.
//

public struct CardSubscriptionPage: PageWithActionTrackable {
    public let strategy: TrackerPageAssociated?
    public typealias ActionType = Action
    public let page: String
    public let easyPay = "pago_facil"
    public enum Action: String {
        case seeMorePayments = "ver_mas_pagos"
        case seeInactiveShops = "ver_comercios_desactivados"
        case seeHistoricPayments = "ver_historico_pagos"
        case fractionatedSubscription = "fraccionar_suscripcion"
        case enableSubscription = "activar_suscripcion"
        case disableSubscription = "desactivar_suscripcion"
        case screenIdSignature = "firma_activar_suscripcion"
        case screenIdOtp = "otp_activar_suscripcion"
    }
    
    public init(strategy: TrackerPageAssociated? = nil) {
        self.strategy = strategy
        self.page = strategy?.pageAssociated ?? ""
    }
}

public struct CardSubscriptionGeneralPage: TrackerPageAssociated {
    public let pageAssociated = "listado_pagos_recurrentes_general"
    public init() {}
}

public struct CardSubscriptionCardPage: TrackerPageAssociated {
    public let pageAssociated = "listado_pagos_recurrentes_tarjeta"
    public init() {}
}

public struct CardSubscriptionDetailPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "detalle_pago_recurrente"
    public let easyPay = "pago_facil"
    public enum Action: String {
        case fractionatedSubscription = "fraccionar_suscripcion"
        case enableSubscription = "activar_suscripcion"
        case disableSubscription = "desactivar_suscripcion"
        case seeInactiveShops = "desplegable_ver_mas_pagos"
    }
    public init() {}
}

public struct CardControlDistributionPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "distribuidora_pagos_recurrentes"
    public enum Action: String {
        case seeRecurringPaymentsList = "ver_listado_pagos_recurrentes"
        case seeSubscriptions = "ver_suscripciones"
    }
    
    public init() {}
}

public enum CardSubscriptionDetailSubscriptionType: String {
    case activate = "activar_suscripcion"
    case deactivate = "desactivar_suscripcion"
}
