//
//  FeesInfoRepresentable.swift
//  CoreDomain
//
//  Created by Hernán Villamil on 21/4/22.
//

import Foundation

public protocol FeesInfoRepresentable {
    var settlementDate: String? { get }
    var comission: Int? { get }
    var interests: Double? { get }
    var feeImport: Double? { get }
    var totalImport: Double? { get }
    var taeImport: Double? { get }
    var personCode: Int? { get }
    var personType: String? { get }
    var currency: String { get }
    var totalMonths: Int? { get }
}
