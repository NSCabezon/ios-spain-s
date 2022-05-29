//
//  IdActuantePayeeRepresentable.swift
//  CoreDomain
//
//  Created by Juan Diego Vázquez Moreno on 25/1/22.
//

public protocol IdIssuerPayeeRepresentable {
    var bankCode: String? { get }
    var actingTypeCode: String? { get }
    var actingNumber: String? { get }
}
