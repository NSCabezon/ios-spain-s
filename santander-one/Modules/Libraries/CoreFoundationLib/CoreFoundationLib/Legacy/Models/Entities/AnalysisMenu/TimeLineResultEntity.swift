//
//  TimeLineResultEntity.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 20/03/2020.
//

import Foundation
/**
  listado de movimientos que presentarán información  agrupada por tipo y categoría de movimiento de gasto
 - Fila 1 al menos 1 prestamo, Has reducido tu deuda: Se sumarán los movimientos de tipo "104" y "105".
     
 - Transferencias : 100" y "101" de las cuentas que el cliente tenga visibles, teniendo en cuenta que las emitidas vendrán con signo negativo en el importe y las recibidas con positivo, por lo que mostraremos la diferencia. Los traspasos vendrán uno con cada signo, por lo que no habrá que hacer un tratamiento especial.
     
 - Bizum: Se agruparán los movimientos de tipo "109" de las cuentas que el cliente tenga visibles, que  lleven en el campo "merchant" el código que identificará a bizum (pendiente de definir) y, como en el caso de transferencias,  los bizum emitidos vendrán con signo negativo en el importe y los recibidos con positivo, por lo que mostraremos la diferencia entre todos ellos. Se mostrará el nº de móvil desde el que se han hecho los envíos enmascarado excepto los últimos 3 dígitos.
     
 - Suscripciones: son movimientos de asociación de una suscripción a una tarjeta de crédito (por ejemplo HBO, etc) Se sumarán todos los movimientos de tipo "103" de las tarjetas que el cliente tenga visibles. Como en los casos anteriores, si hubiera algún movimiento de este tipo con signo positivo, se pintará la diferencia entre éste y los de signo negativo.
     
 - Recibos : se sumarán todos los movimientos de tipo "102" de las cuentas que el cliente tenga visibles, almacenándolo en local por meses. Debemos agrupar mensualmente los recibos por emisora basándonos en el campo "merchant" para poder pintar la línea debajo del importe del número de entidades que han emitido recibos ese mes.
 */
public struct TimeLineResultEntity {
   public var receipts: [TimeLineReceiptEntity]?
   public var transfersIn: [TimeLineTransfersEntity]?
   public var transfersOut: [TimeLineTransfersEntity]?
   public var transfersScheduled: [TimeLineTransfersEntity]?
   public var reducedDebt: [TimeLineDebtEntity]?
   public var subscriptions: [TimeLineSubscriptionEntity]?
   public var bizumsIn: [TimeLineBizumEntity]?
   public var bizumsOut: [TimeLineBizumEntity]?
   public var bizumPhoneNumber: String?
    
   public init () {}
}
