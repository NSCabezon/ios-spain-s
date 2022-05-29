
public struct UpdateSubscriptionSummaryPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "listado_pagos_recurrentes_tarjeta"

    public enum Action: String {
        case opinator = "summary_activar_desactivar_suscripcion_ayudanos_a_mejorar"
    }
    
    public init() {}
}
