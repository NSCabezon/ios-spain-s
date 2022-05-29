//
//  EasyPayConstants.swift
//  Commons
//
//  Created by alvola on 17/12/2020.
//

public enum EasyPayConstants {
    public static let minFees = 2
    public static let maxFees = 36
    public static let pressDelay = 0.5
    public static let minimumAmount = 60.0
}

public struct EasyPayMovementsSelectorPage: PageTrackable {
    public let page = "tarjetas_pago facil_listado_conjunto_movimientos"
    public init() {}
}

public struct EasyPayEmptySelectorPage: PageTrackable {
    public let page = "tarjetas_pago facil_no_tienes_compras_para_financiar"
    public init() {}
}

public struct EasyPayConfigurationPage: PageWithActionTrackable {
    public let page = "pago_facil_proceso"
    public typealias ActionType = Action
    
    public enum Action: String {
        case continueAction = "continuar"
        case fractionateAction = "fraccionar"
        case changeFees = "cambiarCuotas"
    }
    public init() {}
}

public struct EasyPaySummaryPage: PageTrackable {
    public let page = "pago_facil_resumen"
    public init() {}
}

public struct EasyPayFractionablePage: PageWithActionTrackable {
    public let page = "pago_facil_consulta_compras"
    public typealias ActionType = Action
    
    public enum Action: String {
        case goDetail = "fraccionados_detalle"
        case goEndedDetail = "finalizados_detalle"
        case showEnded = "finalizados_link"
        case goToDetailFractionable = "fraccionables_carrusel_detalle"
        case swipeFractionable = "fraccionables_carrusel_swipe"
    }
    public init() {}
}

public struct EasyPayFractionableDetailPage: PageWithActionTrackable {
    public let page = "pago_facil_detalle_compra_fraccionada"
    public typealias ActionType = Action
    public enum Action: String {
        case swipe = "swipe_carrusel"
        case expandable = "desplegar_detalle"
    }
    
    public init() {}
}

public struct EasyPayAllFractionablePurchasesPage: PageWithActionTrackable {
    public let page = "pago_facil_listado_fraccionables"
    public typealias ActionType = Action
    public enum Action: String {
        case goToDetail = "listado_fraccionables_detalle"
        case showFractionateOptions = "listado_fraccionables_fraccionar"
    }
    
    public init() {}
}
